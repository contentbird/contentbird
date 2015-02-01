class CB::Access::Channel
  def info_for_prefix prefix
    channel = CB::Core::Channel.opened.for_prefix(prefix).only_basic_info.first
    if channel
      [true, {key: channel.id, secret_key: channel.access_token, type: channel.simple_type}]
    else
      [false, {error: :not_found, message: 'No channel matches this url prefix'}]
    end
  end

  def channel_for_credentials key, secret
    channel = CB::Core::Channel.opened.for_credentials(key, secret).first
    if channel
      [true, channel]
    else
      [false, {error: :not_authorized, message: 'No channel matches your credentials'}]
    end
  end
end