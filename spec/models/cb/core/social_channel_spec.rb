require 'spec_helper'
require 'cb/core/channel'

describe CB::Core::SocialChannel do
  subject {CB::Core::SocialChannel.new}

  it 'generates new access_token, persists and supports mass assignment' do
    SecureRandom.stub(:hex).and_return('generated_token')
    channel = CB::Core::SocialChannel.create(name: 'SocialChannel Name', url_prefix: 'so_chan', owner_id: 3, provider: 'twitter')
    channel.reload

    channel.closed_at.should             eq nil
    channel.name.should                  eq 'SocialChannel Name'
    channel.url_prefix.should            eq 'so_chan'
    channel.owner_id.should              eq 3
    channel.access_token.should          eq 'generated_token'
    channel.provider.should              eq 'twitter'
    channel.provider_oauth_token.should  eq nil
    channel.provider_oauth_secret.should eq nil
    channel.allow_social_feed.should     be_false
  end

  describe 'validations' do
    it { should validate_presence_of   :provider }

    it { should     allow_value('twitter', 'facebook', 'linkedin').for(:provider) }
    it { should_not allow_value('invalid').for(:provider) }
  end

  describe 'accessors' do
    it '#provider_class returns the CB:Publish class matching the channel\'s provider' do
      CB::Core::SocialChannel.new(provider: 'twitter').provider_class.should eq CB::Publish::Twitter
    end
    it '#pretty_type returns a human readable version of the ugly namespaced type and the provider' do
      subject.provider = 'twitter'
      subject.pretty_type.should eq "Social - Twitter"
    end
  end
end