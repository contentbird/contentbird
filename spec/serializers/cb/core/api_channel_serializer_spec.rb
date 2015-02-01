describe CB::Core::APIChannelSerializer do

  let(:channel) { CB::Core::APIChannel.new(name: 'Channel Name', url_prefix: 'chan', owner_id: 3) }
  subject       { CB::Core::APIChannelSerializer.new(channel) }

  describe '#to_json' do
    it 'returns a well formatted json' do
      subject.to_json.should eq({ name: 'Channel Name',
                                  url_prefix: 'chan'}.to_json)
    end
  end
end