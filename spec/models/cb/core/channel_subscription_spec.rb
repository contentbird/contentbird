require 'spec_helper'
require 'cb/core/channel'

describe CB::Core::ChannelSubscription do

  subject {CB::Core::ChannelSubscription.new}

  describe 'relations' do
    it { should belong_to(:channel).class_name('CB::Core::MessagingChannel').with_foreign_key(:channel_id) }
    it { should belong_to(:contact).class_name('CB::Core::Contact').with_foreign_key(:contact_id) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:contact_id).scoped_to(:channel_id) }
  end

  describe '#find_for_channel_and_email' do
    context 'given a mesaging channel and 2 contacts subscribed to it' do
      before do
        @channel = CB::Core::MessagingChannel.create!(owner_id: 12, name: 'The channel', provider: 'email')
        @channel.contacts.create!(owner_id: 12, email: 'sub1@gmail.com')
        @channel.contacts.create!(owner_id: 12, email: 'sub2@gmail.com')
      end
      it 'returns the subscription matching the given channel and email' do
        subscription = CB::Core::ChannelSubscription.find_for_channel_and_email(@channel, 'sub2@gmail.com')

        subscription.channel_id.should eq @channel.id
        subscription.contact.email.should eq 'sub2@gmail.com'
      end
      it 'returns nil if no subscription matches the given channel and email' do
        CB::Core::ChannelSubscription.find_for_channel_and_email(@channel, 'whatever@luckyguess.com').should be_nil
      end
    end
  end
end