describe CB::Access::Channel do

  subject { CB::Access::Channel.new }

  describe '#info_for_prefix' do
    before do
      @scoped_channels = CB::Core::Channel.should_receive_in_any_order(:opened, {for_prefix: 'my-prefix'}, :only_basic_info)
    end
    it 'returns the id and access_token of the first opened channel matching the given url_prefix' do
      @scoped_channels.stub(:first).and_return(double('creds', id: 12, access_token: 'azerty', simple_type: 'website'))
      subject.info_for_prefix('my-prefix').should eq [true, {key: 12, secret_key: 'azerty', type: 'website'}]
    end

    it 'returns a not_found error if the channel was not found' do
      @scoped_channels.stub(:first).and_return(nil)
      subject.info_for_prefix('my-prefix').should eq [false, {error: :not_found, message: 'No channel matches this url prefix'}]
    end

  end

  describe '#channel_for_credentials' do
    before do
      CB::Core::Channel.should_receive(:opened).and_return(opened_channels = double('opened channels'))
      opened_channels.should_receive(:for_credentials).with('id', 'my_access_token').and_return(@scoped_channels = double('channels'))
    end
    it 'returns the first channel matching the given credentials' do
      @scoped_channels.stub(:first).and_return(channel = double('channel'))
      subject.channel_for_credentials('id', 'my_access_token').should eq [true, channel]
    end
    it 'returns a not_authorized error if no channel matches the given credentials' do
      @scoped_channels.stub(:first).and_return(nil)
      subject.channel_for_credentials('id', 'my_access_token').should eq [false, {error: :not_authorized, message: 'No channel matches your credentials'}]
    end
  end

end