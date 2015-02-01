class ApplicationController < ActionController::Base
  include UserFilteringHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery  with: :exception
  (before_action        :fake_sign_in) if Rails.env.test?
  before_action         :restrict_access, :set_locale
  before_action         :configure_permitted_parameters, if: :devise_controller?
  before_action         :reject_old_browsers

  helper_method         :ios_device?

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up)        { |u| u.permit(:email, :nest_name, :password, :token) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :nest_name, :locale, :password) }
    devise_parameter_sanitizer.for(:password)       { |u| u.permit(:password, :reset_password_token) }
  end

  def ios_device?
    request.user_agent =~ /iPad|iPod|iPhone/i
  end

  def reject_old_browsers
    if browser.ie? && browser.version.to_i < 10
      render 'home/old_browser', layout: 'full_page'
      return false
    end
  end

private
  def set_locale
    unless Rails.env.test?
      if current_user.try(:locale).present?
        I18n.locale = current_user.locale
      else
        I18n.locale = locale_from_accept_language_header || I18n.default_locale
      end
    end
  end

  def force_no_ssl
    redirect_to(protocol: 'http://', status: :moved_permanently) if request.ssl? && Rails.env.production?
  end

  def section section
    @section = section
  end

  def rescuer service
    CB::Util::ServiceRescuer.new(service)
  end

  def after_sign_in_path_for resource
    stored_location_for(resource) || dashboard_path
  end

  def fake_sign_in
    if defined?(GlobalVar) && GlobalVar.user_email and (!signed_in? || (signed_in? && GlobalVar.user_email != current_user.email))
       @user = CB::Core::User.find_by_email(GlobalVar.user_email)
       sign_in @user unless @user.nil?
    end
  end

  def locale_from_accept_language_header
    return nil unless request.env['HTTP_ACCEPT_LANGUAGE'].present?
    parsed_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
  end

end
