require 'webmock/rspec'

Contentbird::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  IP_FILTERING = false
  IP_WHITELIST = { '127.0.0.1'      => 'needed to access dev' }

  REDIS_PROVIDER_URL = 'redis://localhost:6379/'

  CHANNEL_CREDS_LOGIN    = 'channel'
  CHANNEL_CREDS_PASSWORD = 'creds'

  HTTPS_URL        = 'http://example.com'
  STATIC_ASSET_URL = '//example.com'
  FAVICON_PATH     = "favicon_dev.ico"

  TWITTER_OAUTH_CONSUMER_TOKEN  = 'consumer_token'
  TWITTER_OAUTH_CONSUMER_SECRET = 'consumer_secret'

  GOOGLE_KEY    = 'google_key'
  GOOGLE_SECRET = 'google_secret'

  LINKEDIN_API_KEY = 'linkedin_key'
  LINKEDIN_SECRET_KEY = 'linkedin_secret'

  FACEBOOK_APP_ID     = 'fb_app_id'
  FACEBOOK_APP_SECRET = 'fb_app_secret'

  WEBSITE_DOMAIN       = 'contentbird.me'
  WEBSITE_SHORT_DOMAIN = 'cbird.me'

  REGISTRATION_ACTIVE = true

  NEWRELIC_API_URL = 'https://api.newrelic.com/api/v1/accounts/123/applications/234'

  PIWIK = {enabled: false, tracker_root_url: 'stats.contentbird.com/piwik/', site_id: 0}

  WORKER_AUTOSCALE = false
  SCALER_CONFIG = {
                    default:    {min_workers: 0, max_workers: 1, job_threshold: 1, queues: 'send_emails,delete_contents_images,delete_user,propagate_properties_changes,clean_social_publications' }
                  }

  STORAGE = {
              content_image: {  provider: 'Local',
                        url: "/app/storage_mock/image",
                        local_root: "public/system/#{Rails.env}/tmp",
                        folder: "images",
                        conditions: { size: 5242880 },
                        post_process: :resize_image },
              content_image_gallery: {  provider: 'Local',
                        url: "/app/storage_mock/image",
                        local_root: "public/system/#{Rails.env}/tmp",
                        folder: "images",
                        conditions: { size: 5242880 },
                        post_process: :resize_image },
              channel_media: {  provider: 'Local',
                        url: "/app/storage_mock/channel",
                        local_root: "public/system/#{Rails.env}/tmp",
                        folder: "channels",
                        conditions: { size: 1048576 },
                        post_process: nil }
  }

  IMAGE_RESIZER = { resize_url:  '/app/resizer_mock/resize_image',
                    ping_url:    nil }

  JOBS_RUN         = false
  JOBS_SYNCHRONOUS = true

  TEST_EMAIL        = ''
  MAILS_INTERCEPTED = false

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_assets  = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default from:      'ContentBird <contact@contentbird.com>',
                               reply_to:  'no-reply@contentbird.com'
  config.action_mailer.default_url_options   = { host: 'www.contentbird.com' }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  I18n.enforce_available_locales = false
  I18n.default_locale = :test

  WebMock.disable_net_connect!(allow_localhost: true)
end
