require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Contentbird
  class Application < Rails::Application

    config.assets.initialize_on_precompile = false

    config.autoload_paths += Dir["#{config.root}/lib/modules/**/"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
    config.i18n.available_locales = [:fr, :en]

    # On errors, replace <div class="field_with_errors"> with a class error on faulty input
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      class_attr_index = html_tag.index 'class="'
      if class_attr_index
        html_tag.insert class_attr_index+7, 'inputError '
      else
        html_tag.insert html_tag.index('>'), ' class="inputError"'
      end
    end

    config.to_prepare do
      Devise::SessionsController.layout      'public'
      Devise::ConfirmationsController.layout 'public'
      Devise::UnlocksController.layout       'public'
      Devise::PasswordsController.layout     'public'
    end

  end
end
