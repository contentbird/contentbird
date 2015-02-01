require 'spec_helper'

describe CB::Publish::GoogleOauth2 do

  let(:channel)     {c = CB::Core::Channel.new(url_prefix: 't') ; c.id = 12; c.provider_oauth_token = 'token'; c}
  let(:content)     {CB::Core::Content.new(title: 'title', content_type_id: 37)}
  let(:publication) {CB::Core::Publication.new(channel: channel, content: content, url_alias: 'url_alias') }

  subject           { CB::Publish::GoogleOauth2.new(channel) }

  describe '#initialize' do
    it 'stores the passed channel and instantiates a new Google API client with proper authorization' do
      Google::APIClient.stub(:new).with(
        authorization: :oauth_2,
        application_name: 'ContentBird',
        application_version: '0.0.1'
      ).and_return(g_double = double('google double').as_null_object)

      subject.client.should  eq g_double
      subject.channel.should eq channel
    end
  end

  # describe '#format_publication' do
  #   before do
  #     subject.class.stub(:max_tweet_size).and_return(50)
  #   end
  #   context 'given a publication with too long text' do
  #     before do
  #       content.title = "This is a title of my content"
  #     end
  #     it 'returns a string with a link to cb.me publication and the max content caracters possible to comply with tweet size constraint' do
  #       subject.send(:format_publication, publication).should eq "This is a title o... http://t.cbird.me/p/url_alias"
  #     end
  #   end
  #   context 'given a publication with a short text' do
  #     before do
  #       content.title = "Go here:"
  #     end
  #     it 'returns a string with a link to cb.me publication and the content without modification' do
  #       subject.send(:format_publication, publication).should eq "Go here: http://t.cbird.me/p/url_alias"
  #     end
  #   end
  # end

  # describe '#publish' do
  #   before do
  #     subject.stub(:format_publication).with(publication).and_return('formatted_publication')
  #   end

  #   it 'uses the Twitter client to create a tweet with the given publication formatted and returns the tweet id' do
  #     subject.client.should_receive(:update).with('formatted_publication').and_return(double('tweet', id: 78))
  #     subject.publish(publication).should eq [true, 78]
  #   end

  #   it 'returns a proper error message if tweeter rejected the publication' do
  #     exception = Twitter::Error::Forbidden.new('you cannot do this, dude')
  #     subject.client.stub(:update).with('formatted_publication').and_raise(exception)
  #     subject.publish(publication).should eq [false, {message: 'you cannot do this, dude', exception: exception}]
  #   end
  # end

  # describe '#unpublish' do
  #   before do
  #     publication.provider_ref = '309'
  #   end
  #   it 'uses the Twitter client to delete the tweet with the given id and returns true' do
  #     subject.client.should_receive(:status_destroy).with(309).and_return(true)
  #     subject.unpublish(publication).should eq [true, nil]
  #   end

  #   it 'returns false + error message and exception an exception is raised' do
  #     exception = Twitter::Error::UnprocessableEntity.new('You may not delete another user\'s status')
  #     subject.client.stub(:status_destroy).and_raise(exception)
  #     subject.unpublish(publication).should eq [false, {message: 'You may not delete another user\'s status', exception: exception}]
  #   end
  # end
end