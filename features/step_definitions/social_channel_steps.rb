module SocialChannelSteps

  def db_create_social_channel params
    user = CB::Core::User.last if user.nil?
    
    channel_params = params.merge({ oauth: {  provider:    'developer',
                                              info:        { nickname: 'nna' },
                                              credentials: { token: 'token', 
                                                             secret: 'secret' }
                                            }
                                  })
    channel_service = CB::Manage::SocialChannel.new(user)
    
    created, channel = channel_service.create(channel_params)
    raise "db_create_social_channel failed for provider developer with name #{params[:name]} : #{channel.errors.messages}" unless created
    
    updated, channel = channel_service.update(channel.id, params)
    raise "db_create_social_channel failed for provider developer with name #{params[:name]} : #{channel.errors.messages}" unless updated
    
    channel
  end

end

World(SocialChannelSteps)

Given(/^he created the following social channels$/) do |channels|
  channels.hashes.each do |channel_params|
    db_create_social_channel(channel_params)
  end
end