class APIExplorersController < ApplicationController
  layout 'public'

  def show
    set_api_actions
    render :explore
  end

  def select
    set_api_actions
    set_call_params
    render :explore
  end

  def run
    set_api_actions
    set_call_params

    cb_client     = CB::Client::Session.new(@api_key, @api_secret, @api_locale.to_sym, false)
    api_params    = @current_action_params.map{|param| params[:api_params][param[1]]}
    context_array = params[:api_context].split('|').map(&:to_sym)

    whatever, @api_curl     = cb_client.send(@current_action, *api_params, context: context_array, page: params[:api_page], only_curl: true)
    whatever, @api_response = cb_client.send(@current_action, *api_params, context: context_array, page: params[:api_page])

    render :explore
  end

private

  def set_api_actions
    @api_actions = {}
    CB::Client::Session.public_instance_methods(false).each do |m|
      @api_actions[t("api_explorers.methods.#{m}")] = m.to_s unless reserved_methods.include?(m)
    end
    @api_locale = I18n.locale.to_s
  end

  def set_call_params
    @api_key                = params[:api_key]
    @api_secret             = params[:api_secret]
    @api_locale             = params[:api_locale] || I18n.locale.to_s
    @current_action         = whitelist_method_name(params[:current_action]) if params[:current_action].present?
    @current_action_params  = useful_method_params(@current_action)
  end

  def whitelist_method_name input
    allowed_method_names = CB::Client::Session.public_instance_methods(false) - reserved_methods
    return input if allowed_method_names.include?(input.to_sym)
  end

  def useful_method_params method_name
    (CB::Client::Session.public_instance_method(method_name.to_sym).parameters - [[:opt, :options]]) if method_name.present?
  end

  def reserved_methods
    @reserved_methods ||= [:key, :secret, :locale]
  end

end