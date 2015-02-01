require 'koala'

class CB::Publish::Facebook < CB::Publish::Base
  attr_reader :channel, :client

  def initialize channel
    @channel = channel
    @client = Koala::Facebook::API.new(@channel.provider_oauth_token)
  end

  def publish publication
    res = @client.put_wall_post '', format_publication(publication)
    publication.reset_provider_ref(res["id"])
    [ true, res["id"] ]
  rescue => e
    [false, {message: e.message, exception: e}]
  end

  def unpublish publication
    success = unpublish_from_provider(publication.provider_ref)
    publication.reset_provider_ref
    [success, nil, false]
  rescue => e
    [false, {message: e.message, exception: e}, false]
  end

  def unpublish_from_provider provider_ref
    @client.delete_object(provider_ref)
  end

  def check_credentials
    [true, credentials: format_credentials(client.get_object('me'))]
  rescue => e
    [false, {provider: 'facebook', message: e.message, exception: e}]
  end

private

  def format_credentials credentials
    {id: credentials['id'], user_name: credentials['name']}
  end

  def format_publication publication
    @publication = publication
    formated_publication = { name: @publication.content.title,
                             link: publication_link }
    if image = @publication.content.first_image_property_url
      formated_publication[:picture] = force_url_to_http(image)
    end
    formated_publication
  end

end