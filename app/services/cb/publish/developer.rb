class CB::Publish::Developer < CB::Publish::Base
  attr_reader :channel, :client

  def initialize channel
    @channel = channel
    @client = FakeDeveloperClient.new(
      consumer_key:       'consumer_key',
      consumer_secret:    'consumer secret',
      oauth_token:        channel.provider_oauth_token,
      oauth_token_secret: channel.provider_oauth_secret
    )
  end

  def check_credentials
    [true, credentials: format_credentials(client.verify_credentials)]
  rescue => e
    [false, {provider: 'developer', message: e.message, exception: e}]
  end

  def publish publication
    post = client.create_post format_publication(publication)
    publication.reset_provider_ref(post.id)
    [true, post.id]
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
    client.remove_post(provider_ref)
  end

private

  def self.max_post_size
    200
  end

  def format_publication publication
    @publication = publication
    post_with_text(limited_text)
  end

  def format_credentials credentials
    {id: credentials.id, user_name: credentials.screen_name}
  end

  def post_with_text text
    text + space_and_link
  end

  def limited_text
    text            = @publication.content.title
    available_space = self.class.max_post_size - post_with_text(text).size
    available_space >= 0 ? text : text.first(available_space-self.class.more.size) + self.class.more
  end

  def space_and_link
    self.class.sep + publication_link
  end

end

class FakeDeveloperClient
  def initialize credentials
  end

  def verify_credentials
    OpenStruct.new(id: 123456, screen_name: 'account-name')
  end

  def create_post post_data
    OpenStruct.new(id: 'developer-post-ref')
  end

  def remove_post post_ref
    true
  end
end