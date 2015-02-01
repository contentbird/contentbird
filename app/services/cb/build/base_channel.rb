class CB::Build::BaseChannel
  attr_reader :oauth, :clean_user_name

  def initialize oauth
    @oauth = oauth
    @clean_user_name = CB::Util::String.transliterate(user_name)
  end

  def user_name
    oauth[:info][:nickname]
  end

  def channel_name
    "#{name_prefix}#{user_name}"
  end

  def url_prefix_name
    "#{url_prefix}#{clean_user_name}"
  end

  def token
    oauth[:credentials][:token]
  end

  def secret
    oauth[:credentials][:secret]
  end

  def build
    channel = CB::Core::SocialChannel.new(provider:   oauth[:provider],
                                          name:       channel_name,
                                          url_prefix: url_prefix_name)
    channel.provider_oauth_token  = token
    channel.provider_oauth_secret = secret
    channel
  end
end