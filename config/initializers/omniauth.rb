Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer       unless Rails.env.production?
  provider :twitter,        TWITTER_OAUTH_CONSUMER_TOKEN, TWITTER_OAUTH_CONSUMER_SECRET
  provider :google_oauth2,  GOOGLE_KEY, GOOGLE_SECRET, {
    name:        'googleplus',
    access_type: 'offline',
    prompt:      'consent',
    request_visible_actions: 'http://schemas.google.com/CreateActivity',
    scope:       'userinfo.email, userinfo.profile, plus.me, plus.login'
  }
  provider :linkedin, LINKEDIN_API_KEY, LINKEDIN_SECRET_KEY, scope: 'r_basicprofile rw_nus'
  provider :facebook, FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, scope: 'publish_actions'
end

unless Rails.env.production?
  OmniAuth.config.on_failure = Proc.new { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }
end