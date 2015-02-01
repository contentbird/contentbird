require 'spec_helper'
require 'cb/core/channel'

describe CB::Core::APIChannel do
  subject {CB::Core::APIChannel.new}

  it 'generates new access_token, persists and supports mass assignment' do
    SecureRandom.stub(:hex).and_return('generated_token')
    channel = CB::Core::APIChannel.create(name: 'Api Channel Name', url_prefix: 'api-chan', owner_id: 3)
    channel.reload

    channel.closed_at.should             eq nil
    channel.name.should                  eq 'Api Channel Name'
    channel.url_prefix.should            eq 'api-chan'
    channel.owner_id.should              eq 3
    channel.access_token.should          eq 'generated_token'
    channel.pretty_type.should           eq 'API'
  end

  describe 'dynamic section creation' do
    it_should_behave_like "a channel who dynamically creates sections when publishing", CB::Core::APIChannel
  end

end