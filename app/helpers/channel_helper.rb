module ChannelHelper
  def channel_picto channel
    if channel.social?
      # picto du provider social
      provider_picto(channel.provider)
    elsif channel.api?
      #picto api TODO
      "&#xe60b;"
    elsif channel.messaging?
      "&#xe634;"
    else
      #picto website
      "&#xe601;"
    end
  end

  def provider_picto provider
    case provider
    when 'twitter'
      "&#xe600;"
    when 'linkedin'
      "&#xe006;"
    when 'facebook'
      "&#xe002;"
    end
  end

  def channel_edit_link channel, options={}
    path =  if channel.social?
              edit_social_channel_path(channel)
            elsif channel.api?
              edit_api_channel_path(channel)
            elsif channel.messaging?
              edit_messaging_channel_path(channel)
            else
              edit_channel_path(channel)
            end
    link_to '', path, options.merge({data: {icon: raw("&#xe00c;")}})
  end

  def channel_link channel, options={}
    path =  if channel.social?
              social_channel_path(channel)
            elsif channel.api?
              api_channel_path(channel)
            elsif channel.messaging?
              messaging_channel_path(channel)
            else
              channel_path(channel)
            end
    link_to '', path, options.merge({data: {icon: raw("&#xe606;")}})
  end
end