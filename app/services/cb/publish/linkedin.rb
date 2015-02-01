require 'linkedin'

class CB::Publish::Linkedin < CB::Publish::Base
  attr_reader :channel, :client

  def initialize channel
    @channel = channel
    @client = LinkedIn::Client.new
    client.authorize_from_access(channel.provider_oauth_token, channel.provider_oauth_secret)
  end

  def publish publication
    return [true, publication.provider_ref] if publication.provider_ref.present?
    res = client.add_share(format_publication(publication))
    if res && (res.code == '201')
      linkedin_ref = JSON.parse(res.body)["updateKey"]
      publication.reset_provider_ref(linkedin_ref)
      [true, linkedin_ref]
    else
      [false, res.try(:message)]
    end
  rescue => e
    [false, {message: e.message, exception: e}]
  end

  def check_credentials
    [true, credentials: format_credentials(client.profile)]
  rescue => e
    [false, {provider: 'linkedin', message: e.message, exception: e}]
  end

private

  def format_credentials credentials
    {id: nil, user_name: "#{credentials.first_name} #{credentials.last_name}"}
  end

  def self.max_title_size
    200
  end

  def format_publication publication
    @publication = publication
    { 'comment' => nil,
      'content' => {
        'title'               => limited_title,
        'submitted-url'       => publication_link,
        'submitted-image-url' => force_url_to_http(@publication.content.first_image_property_url),
        'description'         => nil
      }
    }
  end

  def limited_title
    title            = @publication.content.title
    available_space = self.class.max_title_size - title.size
    available_space >= 0 ? title : title.first(available_space-self.class.more.size) + self.class.more
  end

end