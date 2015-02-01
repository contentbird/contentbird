Contentbird::Application.configure do
  #Load .env content as ENV variables used for ENV['PORT']
  Hash[File.read('.env').scan(/(.+?)=(.+)/)].each {|k,v| ENV[k.to_s] = v} if File.exist?('.env')
  ENV['PORT'] ||= '3000'

  # Settings specified here will take precedence over those in config/application.rb.
  IP_FILTERING = false
  IP_WHITELIST = { '127.0.0.1'      => 'needed to access dev' }

  REDIS_PROVIDER_URL = 'redis://localhost:6379/'

  CHANNEL_CREDS_LOGIN    = 'channel'
  CHANNEL_CREDS_PASSWORD = 'creds'

  HTTPS_URL        = "http://localhost:#{ENV['PORT']}"
  STATIC_ASSET_URL = "//localhost:#{ENV['PORT']}"
  FAVICON_PATH     = "favicon_dev.ico"

  CB::Client.configure do |config|
    config.api_url = 'https://cb-dev.herokuapp.com'
  end

  TWITTER_OAUTH_CONSUMER_TOKEN  = ENV['TWITTER_OAUTH_CONSUMER_TOKEN']
  TWITTER_OAUTH_CONSUMER_SECRET = ENV['TWITTER_OAUTH_CONSUMER_SECRET']

  GOOGLE_KEY    = ENV['GOOGLE_KEY']
  GOOGLE_SECRET = ENV['GOOGLE_SECRET']

  LINKEDIN_API_KEY = ENV['LINKEDIN_API_KEY']
  LINKEDIN_SECRET_KEY = ENV['LINKEDIN_SECRET_KEY']

  FACEBOOK_APP_ID     = ENV['FACEBOOK_APP_ID']
  FACEBOOK_APP_SECRET = ENV['FACEBOOK_APP_SECRET']

  WEBSITE_DOMAIN       = 'contentbird.me'
  WEBSITE_SHORT_DOMAIN = 'cbird.me'

  REGISTRATION_ACTIVE = true

  NEWRELIC_API_URL = 'https://api.newrelic.com/api/v1/accounts/123/applications/234'

  PIWIK = {enabled: false, tracker_root_url: 'stats.contentbird.com/piwik/', site_id: 0}

  WORKER_AUTOSCALE = false
  SCALER_CONFIG = {
                    default:    {min_workers: 0, max_workers: 1, job_threshold: 1, queues: 'send_emails,delete_contents_images,delete_user,propagate_properties_changes,clean_social_publications' }
                  }

  # STORAGE = {
  #             content_image: {  provider: 'Local',
  #                       url: "/app/storage_mock/image",
  #                       local_root: "public/system/#{Rails.env}/tmp",
  #                       folder: "images",
  #                       conditions: { size: 5242880 },
  #                       post_process: :resize_image },
  #             content_image_gallery: {  provider: 'Local',
  #                       url: "/app/storage_mock/image",
  #                       local_root: "public/system/#{Rails.env}/tmp",
  #                       folder: "images",
  #                       conditions: { size: 5242880 },
  #                       post_process: :resize_image },
  #             channel_media: {  provider: 'Local',
  #                       url: "/app/storage_mock/channel",
  #                       local_root: "public/system/#{Rails.env}/tmp",
  #                       folder: "channels",
  #                       conditions: { size: 1048576 },
  #                       post_process: nil }
  # }

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

  # IMAGE_RESIZER = { resize_url:  '/app/resizer_mock/resize_image',
  #                   ping_url:    nil }

  IMAGE_RESIZER = { resize_url:  'http://cbdev-upload.herokuapp.com/resize_image',
                    ping_url:    'http://cbdev-upload.herokuapp.com/ping' }


  JOBS_RUN         = true
  JOBS_SYNCHRONOUS = true

  TEST_EMAIL        = ''
  MAILS_INTERCEPTED = false

  storage_dirs = ["#{Rails.root}/#{STORAGE[:content_image][:local_root]}/#{STORAGE[:content_image][:folder]}"]
  storage_dirs.each {|dir| FileUtils::mkdir_p(dir) unless FileTest::directory?(dir)}

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "localhost:#{ENV['PORT']}" }
  config.action_mailer.delivery_method = :test
  config.action_mailer.default from:      'ContentBird <contact@contentbird.com>',
                               reply_to:  'no-reply@contentbird.com'

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
end
