require 'spec_helper'
require 'cb/core/channel'

describe CB::Core::MessagingChannel do
  subject {CB::Core::MessagingChannel.new}

  it 'generates new access_token, persists and supports mass assignment' do
    SecureRandom.stub(:hex).and_return('generated_token')
    CB::Core::MessagingChannel.stub(:generate_url_prefix).and_return 'aze123rt'

    channel = CB::Core::MessagingChannel.create(name: 'MessagingChannel Name', owner_id: 3, provider: 'email')
    channel.reload

    channel.closed_at.should             eq nil
    channel.name.should                  eq 'MessagingChannel Name'
    channel.url_prefix.should            eq 'ml-aze123rt'
    channel.owner_id.should              eq 3
    channel.access_token.should          eq 'generated_token'
    channel.provider.should              eq 'email'
  end

  describe 'validations' do
    it { should validate_presence_of   :provider }

    it { should     allow_value('email').for(:provider)   }
    it { should_not allow_value('invalid').for(:provider) }
  end

  describe 'relations' do
    it { should have_many(:subscriptions).class_name('CB::Core::ChannelSubscription').with_foreign_key(:channel_id).dependent(:destroy) }
    it { should have_many(:contacts).through(:subscriptions).class_name('CB::Core::Contact') }
  end

  describe 'accessors' do
    it '#provider_class returns the CB:Publish class matching the channel\'s provider' do
      CB::Core::MessagingChannel.new(provider: 'email').provider_class.should eq CB::Publish::Email
    end
    it '#pretty_type returns a human readable version of the ugly namespaced type and the provider' do
      subject.provider = 'email'
      subject.pretty_type.should eq "Messaging - Email"
    end
  end
end