require 'spec_helper'
require 'linkedin'

describe CB::Publish::Linkedin do

  let(:channel)     {c = CB::Core::Channel.new(url_prefix: 'l') ; c.id = 12; c.provider_oauth_token = 'token' ; c.provider_oauth_secret = 'secret'; c}
  let(:content)     {CB::Core::Content.new(title: 'title', content_type_id: 37)}
  let(:publication) {CB::Core::Publication.new(channel: channel, content: content, url_alias: 'url_alias') }
  subject           { CB::Publish::Linkedin.new(channel) }

  describe '#initialize' do
    it 'stores the passed channel and instantiates a new Linked client with proper creds' do
      LinkedIn::Client.stub(:new).and_return client_double = double('linkedin client')
      client_double.should_receive(:authorize_from_access).with('token', 'secret')

      subject.client.should  eq client_double
      subject.channel.should eq channel
    end
  end

  describe '#format_publication' do
    before do
      subject.class.stub(:max_title_size).and_return(15)
    end
    context 'given a publication with too long title' do
      before do
        content.title = "This is a title of my content"
        content.stub(:first_image_property_url).and_return(nil)
      end
      it 'returns a hash with link and the maximum possible characters to comply with title size constraint' do
        subject.send(:format_publication, publication).should eq({  'comment' => nil,
                                                                    'content' => {
                                                                      'title'               => "This is a ti...",
                                                                      'submitted-url'       => "http://l.cbird.me/p/url_alias",
                                                                      'submitted-image-url' => nil,
                                                                      'description'         => nil
                                                                    }
                                                                  })
      end
    end
    context 'given a publication with a short title and no image' do
      before do
        content.title = "Go here"
        content.stub(:first_image_property_url).and_return(nil)
      end
      it 'returns a hash with a link with link and the title without modification' do
        subject.send(:format_publication, publication).should eq({  'comment' => nil,
                                                                    'content' => {
                                                                      'title'               => "Go here",
                                                                      'submitted-url'       => "http://l.cbird.me/p/url_alias",
                                                                      'submitted-image-url' => nil,
                                                                      'description'         => nil
                                                                    }
                                                                  })
      end
    end
    context 'given a publication with an image' do
      before do
        content.stub(:first_image_property_url).and_return("//mysite.com/img-1383138339.JPG")
      end
      it 'returns a hash with link and the maximum possible characters to comply with title size constraint' do
        subject.send(:format_publication, publication).should eq({  'comment' => nil,
                                                                    'content' => {
                                                                      'title'               => 'title',
                                                                      'submitted-url'       => "http://l.cbird.me/p/url_alias",
                                                                      'submitted-image-url' => "http://mysite.com/img-1383138339.JPG",
                                                                      'description'         => nil
                                                                    }
                                                                  })
      end
    end
  end

  describe '#publish' do
    before do
      subject.stub(:format_publication).with(publication).and_return('formatted_publication')
    end

    it 'uses the client to create a share with the given formatted publication, set the publication provider_ref and returns the share id' do
      json_response = {updateKey: 'updateKey', updateUrl: 'updateUrl'}.to_json
      subject.client.should_receive(:add_share).with('formatted_publication').and_return double('share', code: '201', body: json_response)
      publication.should_receive(:reset_provider_ref).with('updateKey').and_return true
      subject.publish(publication).should eq [true, 'updateKey']
    end

    it 'returns false and error message and do not set the provider_ref if Linked in API returned error' do
      subject.client.stub(:add_share).with('formatted_publication').and_return double('share', code: '500', message: 'oh noo...')
      publication.should_receive(:reset_provider_ref).never
      subject.publish(publication).should eq [false, 'oh noo...']
    end

    it 'returns false and a proper error message and do not set the provider_ref if an exception is raised' do
      exception = SocketError.new('getaddrinfo: nodename nor servname provided, or not known')
      subject.client.stub(:add_share).with('formatted_publication').and_raise(exception)
      publication.should_receive(:reset_provider_ref).never
      subject.publish(publication).should eq [false, {message: 'getaddrinfo: nodename nor servname provided, or not known', exception: exception}]
    end

    context 'given the publication already has a linked_in provider_ref' do
      before do
        publication.provider_ref = 'existing_ref'
      end
      it 'does not republish to linked_in nor update the provider ref' do
        subject.client.should_receive(:add_share).never
        publication.should_receive(:reset_provider_ref).never
        subject.publish(publication).should eq [true, 'existing_ref']
      end
    end
  end

  describe '#unpublish' do
    before do
      publication.provider_ref = '309'
    end

    it 'returns true and asks for a manual unpublication' do
      subject.unpublish(publication).should eq [true, nil, true]
    end
  end

  describe '#check_credentials' do
    it 'returns true if linkedin client says credentials are correct' do
      subject.client.stub(:profile).and_return OpenStruct.new(id: nil, first_name: "Nicolas", headline: "TEST ACCOUNT chez ContentBird", last_name: "TEST")

      subject.check_credentials.should eq [true, credentials: {id: nil, user_name: 'Nicolas TEST'}]
    end
    it 'returns false if twitter client raises an LinkedIn::Errors::UnauthorizedError error' do
      exception = LinkedIn::Errors::UnauthorizedError.new('(401): [unauthorized]. The token used in the OAuth request is not valid. 36')
      subject.client.stub(:profile).and_raise exception

      subject.check_credentials.should eq [false, {provider: 'linkedin', message: '(401): [unauthorized]. The token used in the OAuth request is not valid. 36', exception: exception}]
    end
  end
end