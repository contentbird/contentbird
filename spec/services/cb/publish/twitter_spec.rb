require 'spec_helper'

describe CB::Publish::Twitter do

  let(:channel)     {c = CB::Core::Channel.new(url_prefix: 't') ; c.id = 12; c.provider_oauth_token = 'token' ; c.provider_oauth_secret = 'secret'; c}
  let(:content)     {CB::Core::Content.new(title: 'title', content_type_id: 37)}
  let(:publication) {CB::Core::Publication.new(channel: channel, content: content, url_alias: 'url_alias') }
  subject           { CB::Publish::Twitter.new(channel) }

  describe '#initialize' do
    it 'stores the passed channel and instantiates a new Twitter client with proper creds' do
      Twitter::Client.stub(:new).with(
        consumer_key:       TWITTER_OAUTH_CONSUMER_TOKEN,
        consumer_secret:    TWITTER_OAUTH_CONSUMER_SECRET,
        oauth_token:        channel.provider_oauth_token,
        oauth_token_secret: channel.provider_oauth_secret
      ).and_return 'twitter client'
      subject.client.should  eq 'twitter client'
      subject.channel.should eq channel
    end
  end

  describe '#format_publication' do
    before do
      subject.class.stub(:max_tweet_size).and_return(50)
    end
    context 'given a publication with too long text' do
      before do
        content.title = "This is a title of my content"
      end
      it 'returns a string with a link to cb.me publication and the max content caracters possible to comply with tweet size constraint' do
        subject.send(:format_publication, publication).should eq "This is a title o... http://t.cbird.me/p/url_alias"
      end
    end
    context 'given a publication with a short text' do
      before do
        content.title = "Go here:"
      end
      it 'returns a string with a link to cb.me publication and the content without modification' do
        subject.send(:format_publication, publication).should eq "Go here: http://t.cbird.me/p/url_alias"
      end
    end
  end

  describe '#publish' do
    before do
      subject.stub(:format_publication).with(publication).and_return('formatted_publication')
    end

    it 'uses the Twitter client to create a tweet with the given publication, set the publication provider_ref and returns the tweet id' do
      subject.client.should_receive(:update).with('formatted_publication').and_return(double('tweet', id: 78))
      publication.should_receive(:reset_provider_ref).with(78).and_return true
      subject.publish(publication).should eq [true, 78]
    end

    it 'returns a proper error message and do not set the provider_ref if tweeter rejected the publication' do
      exception = Twitter::Error::Forbidden.new('you cannot do this, dude')
      subject.client.stub(:update).with('formatted_publication').and_raise(exception)
      publication.should_receive(:reset_provider_ref).never
      subject.publish(publication).should eq [false, {message: 'you cannot do this, dude', exception: exception}]
    end
  end

  describe '#unpublish' do
    before do
      publication.provider_ref = '309'
    end

    it 'unpublishes the tweet from twitter, removes the tweet ID from the publication and returns true' do
      subject.should_receive(:unpublish_from_provider).with('309').and_return(true)
      publication.should_receive(:reset_provider_ref).and_return(true)
      subject.unpublish(publication).should eq [true, nil, false]
    end

    it 'returns false + error message and exception if a twitter exception is raised, and does NOT remove the tweet id from the publication' do
      exception = Twitter::Error::UnprocessableEntity.new('You may not delete another user\'s status')
      subject.stub(:unpublish_from_provider).with('309').and_raise(exception)
      publication.stub(:reset_provider_ref).never
      subject.unpublish(publication).should eq [false, {message: 'You may not delete another user\'s status', exception: exception}, false]
    end
  end

  describe '#unpublish_from_provider' do
    it 'uses the Twitter client to delete the tweet with the given id converted to integer and returns what twitter returns' do
      subject.client.should_receive(:status_destroy).with(309).and_return('some value, normally true')
      subject.unpublish_from_provider('309').should eq 'some value, normally true'
    end
    it 'forwards the twitter exception, the catching being done by higher level code' do
      exception = Twitter::Error::UnprocessableEntity.new('You may not delete another user\'s status')
      subject.client.stub(:status_destroy).and_raise(exception)
      expect{subject.unpublish_from_provider('309')}.to raise_error exception
    end
  end

  describe '#check_credentials' do
    it 'returns true if twitter client says credentials are correct' do
      subject.client.stub(:verify_credentials).and_return OpenStruct.new(id: 3746, screen_name: 'nna_test', some: 'data')

      subject.check_credentials.should eq [true, credentials: {id: 3746, user_name: 'nna_test'}]
    end
    it 'returns false if twitter client raises an Twitter::Error::Unauthorized error' do
      exception = Twitter::Error::Unauthorized.new('Invalid or expired token')
      subject.client.stub(:verify_credentials).and_raise exception

      subject.check_credentials.should eq [false, {provider: 'twitter', message: 'Invalid or expired token', exception: exception}]
    end
  end
end