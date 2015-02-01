class CleanSocialPublication < JobBase
	
  acts_as_scalable

  @queue = :clean_social_publications

  def self.do_perform channel_id, provider_ref
  	channel   = CB::Core::Channel.find(channel_id)
  	publisher = channel.provider_class.new(channel)
  	publisher.unpublish_from_provider(provider_ref)
  end

end