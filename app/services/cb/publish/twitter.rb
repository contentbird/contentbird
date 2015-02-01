class CB::Publish::Twitter < CB::Publish::Base
  attr_reader :channel, :client

  def initialize channel
    @channel = channel
    @client = Twitter::Client.new(
      consumer_key:       TWITTER_OAUTH_CONSUMER_TOKEN,
      consumer_secret:    TWITTER_OAUTH_CONSUMER_SECRET,
      oauth_token:        channel.provider_oauth_token,
      oauth_token_secret: channel.provider_oauth_secret
    )
  end

  def check_credentials
    [true, credentials: format_credentials(client.verify_credentials)]
  rescue => e
    [false, {provider: 'twitter', message: e.message, exception: e}]
  end

  def publish publication
    tweet = client.update format_publication(publication)
    publication.reset_provider_ref(tweet.id)
    [true, tweet.id]
  rescue => e
    [false, {message: e.message, exception: e}]
  end

  def unpublish publication
    result = unpublish_from_provider(publication.provider_ref)
    publication.reset_provider_ref
    [true, nil, false]
  rescue => e
    [false, {message: e.message, exception: e}, false]
  end

  def unpublish_from_provider provider_ref
    client.status_destroy(provider_ref.to_i)
  end

private

  def self.max_tweet_size
    140
  end

  def format_publication publication
    @publication = publication
    tweet_with_text(limited_text)
  end

  def format_credentials credentials
    {id: credentials.id, user_name: credentials.screen_name}
  end

  def tweet_with_text text
    text + space_and_link
  end

  def limited_text
    text            = @publication.content.title
    available_space = self.class.max_tweet_size - tweet_with_text(text).size
    available_space >= 0 ? text : text.first(available_space-self.class.more.size) + self.class.more
  end

  def space_and_link
    self.class.sep + publication_link
  end

end