require 'spec_helper'
require 'cb/core/channel'

describe CB::Publish::Email do

  let(:channel)     {c = CB::Core::MessagingChannel.new(url_prefix: 'ml-12345') ; c.id = 12; c.provider = 'email'; c}
  let(:content)     {CB::Core::Content.new(title: 'title', content_type_id: 37)}
  let(:publication) {CB::Core::Publication.new(channel: channel, content: content, url_alias: 'url_alias') }
  subject           { CB::Publish::Email.new(channel) }

  describe '#initialize' do
    it 'stores the passed channel' do
      subject.channel.should eq channel
    end
  end

  describe '#publish' do
    it 'enqueues a SendEmail Job for Sending the email publication and returns [true, nil]' do
      JobRunner.should_receive(:run).with(SendEmail, 'email_publication', 'CB::Core::Publication', publication.id)

      subject.publish(publication).should eq [true, nil]
    end
    it 'returns false and nil if an error is raised while enqueuing SendEmail' do
      e = StandardError.new('some_error')
      JobRunner.stub(:run).with(SendEmail, 'email_publication', 'CB::Core::Publication', publication.id).and_raise e

      subject.publish(publication).should eq [false, {message: e.message, exception: e}]
    end
  end

end