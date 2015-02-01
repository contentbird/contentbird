require 'heroku-api'

class Platform

  attr_reader :client,
              :env,
              :monitoring_api_key,
              :max_throughput_per_web_worker,
              :max_web_workers,
              :min_web_workers,
              :extra_web_workers

  attr_writer :env

  def initialize
    @client = Heroku::API.new(username: ENV['HEROKU_USER'], password: ENV['HEROKU_PASSWORD'])
    @env = ENV['APP_NAME']
    @monitoring_api_url = NEWRELIC_API_URL
    @monitoring_api_key = ENV['NEW_RELIC_API_KEY']
    load_scaling_settings
  end

  def ps type=''
    ps = @client.get_ps(@env).body
  	type.empty? ? ps : ps.select{|h| h['process'].starts_with?(type)}
  end

  def ps_scale type, qty
    @client.post_ps_scale(@env, type, qty).body
  end

  def ps_restart process
    @client.post_ps_restart(@env, 'ps' => process).body
  end

  def ps_restart_type type
    @client.post_ps_restart(@env, 'type' => type).body
  end

  def ps_count type=''
    ps(type).size
  end

  def throughput
    monitoring_response = ask_newrelic_for_throughput
    return nil unless monitoring_response.class == Net::HTTPOK

    raw_metrics = JSON.parse(monitoring_response.body)
    valid_metrics = raw_metrics.map{|m| m['calls_per_minute'].to_i unless m['calls_per_minute'].to_i.zero? }.compact

    return nil if valid_metrics.size < 2
    total_throughput = valid_metrics.inject(:+)
    total_throughput / valid_metrics.size
  rescue Timeout::Error
    return nil
  end

  def autoscale_web_workers
    return false unless can_autoscale_web_workers? && web_auto_scaling_activated?

    current_workers   = ps_count('web')
    target_workers    = nb_web_workers_needed || current_workers

    if current_workers != target_workers && !web_workers_out_of_bounds(current_workers)
      ps_scale('web',target_workers)
      restart_added_web_workers(current_workers, target_workers)
    end
  end

  def web_auto_scaling_activated?
    AppSetting['scale_auto_activated'] == 'true'
  end

  def activate_web_auto_scaling
    AppSetting['scale_auto_activated'] = 'true'
  end

  def desactivate_web_auto_scaling
    AppSetting['scale_auto_activated'] = 'false'
  end


  private

  def restart_added_web_workers current_workers, target_workers
    if current_workers < target_workers
      wait_for_process_to_boot
      (current_workers+1..target_workers).each {|process_number| ps_restart("web.#{process_number}")}
    end
  end

  def wait_for_process_to_boot
    sleep(60) if Rails.env.production?
  end

  def optimal_nb_web_workers
    (throughput / max_throughput_per_web_worker).to_i + 1 + extra_web_workers
  end

  def nb_web_workers_needed
    limit_to_bounds(optimal_nb_web_workers)
  rescue
    false
  end

  def limit_to_bounds needed_workers
    needed_workers    = max_web_workers if needed_workers > max_web_workers
    needed_workers    = min_web_workers if needed_workers < min_web_workers
    needed_workers
  end

  def web_workers_out_of_bounds nb_workers
    nb_workers < min_web_workers || nb_workers > max_web_workers
  end

  def can_autoscale_web_workers?
    max_throughput_per_web_worker && max_web_workers && min_web_workers && extra_web_workers
  end

  def load_scaling_settings
    settings = AppSetting.like('scale_')
    @max_throughput_per_web_worker  = settings['scale_max_throughput_per_web_worker'].to_i
    @max_web_workers                = settings['scale_max_web_workers'].to_i
    @min_web_workers                = settings['scale_min_web_workers'].to_i
    @extra_web_workers              = settings['scale_extra_web_workers'].to_i
  end

  def ask_newrelic_for_throughput
    begin_time = I18n.l(5.minutes.ago.utc, format: :z)
    end_time   = I18n.l(Time.now.utc, format: :z)

    uri = URI.parse("#{@monitoring_api_url}/data.json?metrics[]=WebFrontend/QueueTime&field=calls_per_minute&begin=#{begin_time}&end=#{end_time}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Timeout::timeout(2) do
      req = Net::HTTP::Get.new(uri.request_uri)
      req['x-api-key'] = [monitoring_api_key]
      req
    end
    response = http.request(request)
  end

end