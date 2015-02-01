Contentbird::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  IP_FILTERING = ENV['IP_FILTERING'] == 'true'
  IP_WHITELIST = {  '31.35.37.50'    => 'ATH IP',
                    '81.57.249.138'  => 'NNA_IP',
                    '90.0.231.184'   => 'FRONTITI_IP',
                    '81.64.214.211'  => 'SEB_IP',
                    '194.3.201.129'  => 'arizona.france-loisirs.com: proxy Actissia',
                    '89.107.173.228' => 'proxy SAGA',
                    '194.3.201.66'   => 'proxy FL',
                    '127.0.0.1'      => 'Possible heroku self http call' }

  REDIS_PROVIDER_URL = ENV['REDISTOGO_URL']

  CHANNEL_CREDS_LOGIN    = ENV['CHANNEL_CREDS_LOGIN']
  CHANNEL_CREDS_PASSWORD = ENV['CHANNEL_CREDS_PASSWORD']

  HTTPS_URL        = ENV['CB_API_URL'] if ENV['CB_API_URL']
  STATIC_ASSET_URL = ENV['STATIC_ASSET_URL']
  FAVICON_PATH     = "favicon.ico"

  CB::Client.configure do |config|
    config.api_url = ENV['CB_API_URL'] if ENV['CB_API_URL']
  end

  TWITTER_OAUTH_CONSUMER_TOKEN  = ENV['TWITTER_OAUTH_CONSUMER_TOKEN']
  TWITTER_OAUTH_CONSUMER_SECRET = ENV['TWITTER_OAUTH_CONSUMER_SECRET']

  GOOGLE_KEY    = ENV['GOOGLE_KEY']
  GOOGLE_SECRET = ENV['GOOGLE_SECRET']

  LINKEDIN_API_KEY = ENV['LINKEDIN_API_KEY']
  LINKEDIN_SECRET_KEY = ENV['LINKEDIN_SECRET_KEY']

  FACEBOOK_APP_ID     = ENV['FACEBOOK_APP_ID']
  FACEBOOK_APP_SECRET = ENV['FACEBOOK_APP_SECRET']

  WEBSITE_DOMAIN       = ENV['WEBSITE_DOMAIN']
  WEBSITE_SHORT_DOMAIN = ENV['WEBSITE_SHORT_DOMAIN']

  REGISTRATION_ACTIVE = ENV['REGISTRATION_ACTIVE'] == 'true'

  NEWRELIC_API_URL = "https://api.newrelic.com/api/v1/accounts/#{ENV['NEW_RELIC_ID']}/applications/#{ENV['NEW_RELIC_APP_ID']}"

  PIWIK = {enabled: (ENV['PIWIK_ENABLED'] == 'true'), tracker_root_url: 'stats.contentbird.com/piwik/', site_id: ENV['PIWIK_SITE_ID']}

  WORKER_AUTOSCALE = ENV['WORKER_AUTOSCALE'] == 'true'
  SCALER_CONFIG = {
                    default:    {min_workers: 0, max_workers: 1, job_threshold: 1, queues: 'send_emails,delete_contents_images,delete_user,propagate_properties_changes,clean_social_publications' }
                  }

  STORAGE = {
    content_image: {
            provider:   'AWS',
            url:        "//#{ENV['S3_IMAGE_BUCKET']}.s3-external-3.amazonaws.com",
            access_key: ENV['S3_KEY'],
            secret_key: ENV['S3_SECRET'],
            bucket:     ENV['S3_IMAGE_BUCKET'],
            conditions: { size: 5242880 },
            post_process: :resize_image,
            region:     'eu-west-1'
                    },
    content_image_gallery: {
            provider:   'AWS',
            url:        "//#{ENV['S3_IMAGE_BUCKET']}.s3-external-3.amazonaws.com",
            access_key: ENV['S3_KEY'],
            secret_key: ENV['S3_SECRET'],
            bucket:     ENV['S3_IMAGE_BUCKET'],
            conditions: { size: 5242880 },
            post_process: :resize_image,
            region:     'eu-west-1'
                    },
    channel_media: {
            provider:   'AWS',
            url:        "//#{ENV['S3_CHANNEL_BUCKET']}.s3-external-3.amazonaws.com",
            access_key: ENV['S3_KEY'],
            secret_key: ENV['S3_SECRET'],
            bucket:     ENV['S3_CHANNEL_BUCKET'],
            conditions: { size: 1048576 },
            post_process: nil,
            region:     'eu-west-1'
                    }
            }

  IMAGE_RESIZER = { resize_url:  ENV['IMAGE_RESIZER_URL'] + '/resize_image',
                    ping_url:    ENV['IMAGE_RESIZER_URL'] + '/ping' }

  JOBS_RUN         = true
  JOBS_SYNCHRONOUS = false

  TEST_EMAIL        = "test@contentbird.com"
  MAILS_INTERCEPTED = ENV['MAILS_INTERCEPTED'] == 'true'


  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.6'

  config.assets.precompile += Dir["#{Rails.root}/app/assets/javascripts/specifics/*"].map {|e| 'specifics/'+File.basename(e,'.coffee')}
  config.assets.precompile += Dir["#{Rails.root}/app/assets/stylesheets/plugins/epiceditor/*"].map {|e| 'plugins/epiceditor/'+File.basename(e,'.scss')}
  config.assets.precompile += Dir["#{Rails.root}/app/assets/stylesheets/admin.css.scss"]
  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method       = :smtp
  config.action_mailer.default_options       = { from:      'ContentBird <contact@contentbird.com>',
                                                 reply_to:  'no-reply@contentbird.com' }
  config.action_mailer.default_url_options   = { host: 'www.contentbird.com' }
  config.action_mailer.smtp_settings = {
    address:        "smtp.sendgrid.net",
    port:           "587",
    authentication: :plain,
    user_name:      ENV['SENDGRID_USERNAME'],
    password:       ENV['SENDGRID_PASSWORD'],
    domain:         'contentbird.com'
  }

  # mail interception for pre-production envs
  if MAILS_INTERCEPTED
    require 'mail/outgoing_mail_interceptor'
    ActionMailer::Base.register_interceptor OutgoingMailInterceptor
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
end
