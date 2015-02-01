source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails', '4.0.5'
gem 'rails-i18n', '~> 4.0.0'

#gem 'heroku' #Still needed to run pgbackups command from heroku platform

gem "heroku-api", git: 'https://github.com/heroku/heroku.rb.git', branch: 'master' #no gem with excon dependency >= 0.27 available

gem 'pg'
gem 'hiredis'
gem 'redis'

gem 'fog'

group :dependency do
  gem 'websocket-driver', '=0.3.0' #0.3.1 fails with ruby 2.0 see here https://github.com/faye/websocket-driver-ruby/issues/12
end

gem 'resque'
gem 'resque-scheduler', require: 'resque_scheduler'

gem 'rack-timeout'

gem 'devise'
gem 'friendly_id'
gem 'active_model_serializers'

gem 'kaminari'

gem 'twitter'
gem 'google-api-client'
gem 'linkedin'
gem 'koala'

gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin'
gem 'omniauth-facebook'

gem 'cb-render', git: 'https://github.com/contentbird/cb-render.git', branch: 'master'
gem 'cb-api',    git: 'https://github.com/contentbird/cb-api.git',    branch: 'master'

gem 'carrierwave'
gem 'rmagick'

gem 'griddler'

group :production do
  gem 'unicorn'
  gem 'dalli'
  gem 'newrelic_rpm'
  gem 'rails_log_stdout',           git: 'https://github.com/heroku/rails_log_stdout.git', branch: 'master'
  gem 'rails3_serve_static_assets', git: 'https://github.com/heroku/rails3_serve_static_assets.git', branch: 'master'
end

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', require: false
end

gem 'jquery-rails'
gem 'turbolinks'
gem 'browser'

group :development, :test do
  gem 'therubyracer', '=0.11.4'
  gem 'libv8'
end

group :test do
  gem 'simplecov', require: false
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_girl'
  gem 'shoulda-matchers'
  gem 'email_spec'
  gem 'webmock'

  gem 'cucumber-rails', require: false
  gem 'database_cleaner'

  gem 'guard-rspec', require: false
  gem 'rspec-nc'
end