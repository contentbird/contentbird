class CB::Manage::SocialChannel < CB::Manage::Channel

  def build_new params={}
    channel = if params[:oauth].present?
                channel_builder = "CB::Build::#{params[:oauth][:provider].camelize}Channel".constantize
                channel_builder.send(:new, params[:oauth]).build
              else
                CB::Core::SocialChannel.new params
              end
  end

  def check_credentials key
    channel  = find(key)
    provider = channel.provider_class.new(channel)
    provider.check_credentials
  end

  def update_credentials key, oauth
    channel = find(key)
    channel.provider_oauth_token  = oauth[:credentials][:token]
    channel.provider_oauth_secret  = oauth[:credentials][:secret]
    result  = channel.save
    [result, channel]
  end

end