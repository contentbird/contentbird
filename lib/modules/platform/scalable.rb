module Scalable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_scalable *args
      @wtype      = args[0].nil? ? :default : (args[0][:worker].nil?     ? :default : args[0][:worker])
      @scale_down = args[0].nil? ? true     : (args[0][:scale_down].nil? ? true     : args[0][:scale_down])
      self.instance_eval do
        def scale_down?
          WORKER_AUTOSCALE && @scale_down
        end

        def worker_type
          @wtype
        end

        def conf
          SCALER_CONFIG[worker_type]
        end

        def min_workers
          conf[:min_workers]
        end

        def max_workers
          conf[:max_workers]
        end

        def job_threshold
          conf[:job_threshold]
        end

        def queues
          conf[:queues].split(',')
        end

        def worker_name
          worker_type == :default ? 'worker' : worker_type.to_s + '_worker'
        end

        def job_count
          sum = 0
          queues.each{|q| sum += Resque.size(q)}
          sum
        end

        def nb_workers_needed
          nb_jobs = job_count
          return min_workers if nb_jobs < job_threshold
          ideal_nb_workers_needed = (nb_jobs/job_threshold).to_i + 1
          return ideal_nb_workers_needed > max_workers ? max_workers : ideal_nb_workers_needed
        end

        def scale_up!
          return unless WORKER_AUTOSCALE
          target_nb_workers = nb_workers_needed
          return if target_nb_workers <= min_workers
          platform = Platform.new
          current_nb_workers = platform.ps(worker_name).count
          if current_nb_workers < target_nb_workers
            platform.ps_scale(worker_name, target_nb_workers)
          end
        end

        def scale_down!
          return unless scale_down?
          target_nb_workers = nb_workers_needed
          return if target_nb_workers <= min_workers && min_workers > 0
          platform = Platform.new
          current_nb_workers = platform.ps(worker_name).count
          if current_nb_workers > target_nb_workers
            platform.ps_scale(worker_name, target_nb_workers)
          end
        end

        def after_enqueue_scale_up(*args)
          Thread.new do
            scale_up!
          end
        end

        def after_perform_scale_down(*args)
          scale_down!
        end
      end
    end
  end

end