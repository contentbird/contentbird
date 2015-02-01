require 'spec_helper'
require 'koala'

describe CB::Publish::Facebook do

  let(:channel)     {c = CB::Core::Channel.new(url_prefix: 'fb') ; c.id = 12; c.provider_oauth_token = 'token' ; c.provider_oauth_secret = 'secret'; c}
  let(:content)     {CB::Core::Content.new(title: 'title', content_type_id: 37)}
  let(:publication) {CB::Core::Publication.new(channel: channel, content: content, url_alias: 'url_alias') }
  subject           { CB::Publish::Facebook.new(channel) }

  describe '#initialize' do
    it 'stores the passed channel and instantiates a new Koala client with proper creds' do
      Koala::Facebook::API.stub(:new).with('token').and_return client_double = double('facebook client')
      subject.client.should  eq client_double
      subject.channel.should eq channel
    end
  end

  describe '#format_publication' do
    context 'given a publication with no image' do
      before do
        content.title = "This is a title of my content"
        content.stub(:first_image_property_url).and_return(nil)
      end
      it 'returns a hash with the title, the link, and no picture' do
        subject.send(:format_publication, publication).should eq({  name: 'This is a title of my content',
                                                                    link: "http://fb.cbird.me/p/url_alias" })
      end
    end

    context 'given a publication with an image' do
      before do
        content.stub(:first_image_property_url).and_return("//mysite.com/img-1383138339.JPG")
      end
      it 'returns a hash with the title, the link, and the image url for picture' do
        subject.send(:format_publication, publication).should eq({  name: 'title',
                                                                    link: "http://fb.cbird.me/p/url_alias",
                                                                    picture: 'http://mysite.com/img-1383138339.JPG'  })
      end
    end
  end

  describe '#publish' do
    before do
      subject.stub(:format_publication).with(publication).and_return('formatted_publication')
    end

    it 'uses the client to create a share with the given publication formatted, set the publication provider_ref and returns the share id' do
      subject.client.should_receive(:put_wall_post).with('', 'formatted_publication').and_return({'id' => 'thefacebookpostid'})
      publication.should_receive(:reset_provider_ref).with('thefacebookpostid').and_return true
      subject.publish(publication).should eq [true, 'thefacebookpostid']
    end

    it 'returns false and a proper error message and do not set the provider_ref if an exception is raised' do
      exception = SocketError.new('getaddrinfo: nodename nor servname provided, or not known')
      subject.client.stub(:put_wall_post).with('', 'formatted_publication').and_raise(exception)
      publication.should_receive(:reset_provider_ref).never
      subject.publish(publication).should eq [false, {message: 'getaddrinfo: nodename nor servname provided, or not known', exception: exception}]
    end
  end

  describe '#unpublish' do
    before do
      publication.provider_ref = '309'
    end

    it 'unpublishes the post from facebook, removes the tweet ID from the publication and returns true' do
      subject.should_receive(:unpublish_from_provider).with('309').and_return(true)
      publication.should_receive(:reset_provider_ref).and_return(true)
      subject.unpublish(publication).should eq [true, nil, false]
    end

    it 'returns false + error message and exception an exception is raised, and does NOT remove the facebook publication id from the publication' do
      exception = SocketError.new('getaddrinfo: nodename nor servname provided, or not known')
      subject.stub(:unpublish_from_provider).with('309').and_raise(exception)
      publication.should_receive(:reset_provider_ref).never
      subject.unpublish(publication).should eq [false, {message: 'getaddrinfo: nodename nor servname provided, or not known', exception: exception}, false]
    end
  end

  describe '#unpublish_from_provider' do
    it 'uses the Koala client to delete the wall post with the given id and returns what facebook returns' do
      subject.client.should_receive(:delete_object).with('309').and_return('some value, normally true')
      subject.unpublish_from_provider('309').should eq 'some value, normally true'
    end
    it 'forwards the facebook exception, the catching being done by higher level code' do
      exception = SocketError.new('getaddrinfo: nodename nor servname provided, or not known')
      subject.client.stub(:delete_object).with('309').and_raise(exception)
      expect{subject.unpublish_from_provider('309')}.to raise_error exception
    end
  end

  describe '#check_credentials' do
    it 'returns true if fb client says credentials are correct by returning the user object' do
      subject.client.stub(:get_object).with('me').and_return({"id"=>"100007862885638", "name"=>"Betty Amghfbhhefch Warmansen", "first_name"=>"Betty"})

      subject.check_credentials.should eq [true, credentials: {id: "100007862885638", user_name: 'Betty Amghfbhhefch Warmansen'}]
    end

    it 'returns false if twitter client raises an Twitter::Error::Unauthorized error' do
      exception = Koala::Facebook::AuthenticationError.new('OAuthException', '190', 'Invalid OAuth access token')
      subject.client.stub(:get_object).with('me').and_raise exception

      subject.check_credentials.should eq [false, {provider: 'facebook', message: 'Invalid OAuth access token [HTTP OAuthException]', exception: exception}]
    end
  end
end