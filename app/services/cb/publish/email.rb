class CB::Publish::Email < CB::Publish::Base
  attr_reader :channel

  def initialize channel
    @channel = channel
  end

  def publish publication
    JobRunner.run(SendEmail, 'email_publication', 'CB::Core::Publication', publication.id)
    [true, nil]
  rescue => e
    [false, {message: e.message, exception: e}]
  end

end