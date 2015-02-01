describe CB::Core::SocialChannelSerializer do

  let(:channel) { CB::Core::SocialChannel.new(name: 'Channel Name', url_prefix: 'chan', owner_id: 3, baseline: 'the top baseline', provider: 'twitter') }
  subject       { CB::Core::SocialChannelSerializer.new(channel) }

  describe '#to_json' do
    it 'returns a well formatted json' do
      channel.stub(:css).and_return(double('css', url: 'my/css/url'))
      channel.stub(:cover_url).and_return('cover/my_cover.jpg')
      subject.to_json.should eq({ name: 'Channel Name',
                                  url_prefix: 'chan',
                                  baseline: 'the top baseline',
                                  allow_social_feed: false,
                                  css_url: 'my/css/url',
                                  cover_url: 'cover/my_cover.jpg',
                                  provider: 'twitter'}.to_json)
    end
  end
end