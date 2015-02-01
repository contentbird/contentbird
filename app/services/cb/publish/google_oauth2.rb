require 'google/api_client'
require 'google/api_client/client_secrets'

class CB::Publish::GoogleOauth2
  attr_reader :channel, :client

  def initialize channel
    @channel = channel
    @client = Google::APIClient.new(
      authorization: :oauth_2,
      application_name: 'ContentBird',
      application_version: '0.0.1'
    )

    # TODO optimize all this client init stuff to do this only once (on application load : initilizer ?)

    # Initialize Google+ API. Note this will make a request to the
    # discovery service every time, so be sure to use serialization
    # in your production code. Check the samples for more details.
    @plus = client.discovered_api('plus')

    # Load client secrets from your client_secrets.json.
    client_secrets = Google::APIClient::ClientSecrets.new('web' => {client_id: GOOGLE_KEY, client_secret: GOOGLE_SECRET})

    # Get authorization object from client secrets
    client.authorization = client_secrets.to_authorization
    client.authorization.update_token!(access_token:  channel.provider_oauth_token, refresh_token: channel.provider_oauth_secret)
    nil
  end

  def publish
    # moment = {
    #     :type => 'http://schemas.google.com/CreateActivity',
    #     :target => { :url => "https://developers.google.com/+/web/snippet/examples/photo" }
    # }
    # req_opts = { :api_method => @plus.moments.insert,
    #              :parameters => { :collection => 'vault', :userId => 'me' },
    #              :body_object => moment,
    # }
    # result = client.execute(req_opts)
    # puts result.data.to_yaml
  end
end