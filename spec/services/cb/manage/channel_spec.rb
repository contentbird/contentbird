describe CB::Manage::Channel do
  let(:user) {u = CB::Core::User.new ; u.id = 12; u}
  subject { CB::Manage::Channel.new(user) }

  describe '#initialize' do
    it 'stores the passed user' do
      subject.user.should eq user
    end
  end

  describe '#list' do
    it 'returns all channels owned by the service user' do
      user.stub(:channels).and_return ['the', 'user', 'channels']
      subject.list.should eq ['the', 'user', 'channels']
    end
  end

  describe '#find' do
    it 'returns the channel owned by the service user AND matching the given id' do
      subject.stub(:list).and_return(types=double)
      types.stub(:find).with('37').and_return('a channel')
      subject.find('37').should eq 'a channel'
    end
  end

  describe '#build_new' do
    it 'returns a new channel, passing optional params to the new method' do
      CB::Core::Channel.stub(:new).with({}).and_return('a channel')
      CB::Core::Channel.stub(:new).with({some: 'params'}).and_return('a pre-filled channel')

      subject.build_new.should eq 'a channel'
      subject.build_new({some: 'params'}).should eq 'a pre-filled channel'
    end
  end

  describe '#create' do
    before do
      @params = {'channel' => 'params'}
    end
    it 'creates a new channel with the given params hash, sets the owner, saves it and returns it with success result' do
      subject.stub(:build_new).with(@params).and_return(channel_double = double('channel'))
      channel_double.should_receive(:owner=).with(user)
      channel_double.should_receive(:save).and_return true
      subject.create(@params).should eq [true, channel_double]
    end

    it 'creates a new content_type with the given params hash, sets the owner tries saving it and returns it with failure result because save failed' do
      subject.stub(:build_new).with(@params).and_return(channel_double = double('channel'))
      channel_double.should_receive(:owner=).with(user)
      channel_double.should_receive(:save).and_return false
      subject.create(@params).should eq [false, channel_double]
    end
  end

  describe '#update' do
    before do
      @params = {'channel' => 'params'}
    end
    it 'finds the channel matching the given id, updates it with the given params hash and returns it with success result' do
      subject.stub(:find).with('37').and_return(channel_double = double('channel'))
      channel_double.should_receive(:update_attributes).with(@params).and_return true
      subject.update('37', @params).should eq [true, channel_double]
    end

    it 'finds the channel matching the given id, update it with the given params hash and return it with failure result if update fails' do
      subject.stub(:find).with('37').and_return(channel_double = double('channel'))
      channel_double.should_receive(:update_attributes).with(@params).and_return false
      subject.update('37', @params).should eq [false, channel_double]
    end
  end

  describe '#reset_access_token' do
    before do
      subject.stub(:find).with('37').and_return(@channel_double = double('channel'))
    end
    it 'finds the channel matching the given id, tell model to generate a new token, save it and returns it with success result' do
      @channel_double.should_receive(:generate_access_token).once
      @channel_double.should_receive(:save).and_return(true)
      @channel_double.stub(:access_token).and_return('renewed_token')
      subject.reset_access_token('37').should eq [true, 'renewed_token']
    end

    it 'finds the channel matching the given id, tell model to generate a new token, save it and returns it with failure result if save fails' do
      @channel_double.should_receive(:generate_access_token).once
      @channel_double.should_receive(:save).and_return(false)
      @channel_double.stub(:access_token).and_return('old_token')
      subject.reset_access_token('37').should eq [false, 'old_token']
    end
  end

  describe '#destroy' do
    it 'calls destroys on channel model and return the result and the channel' do
      subject.stub(:find).with('37').and_return(channel_double = double('channel'))
      channel_double.should_receive(:destroy).and_return('I did it')
      subject.destroy('37').should eq ['I did it', channel_double]
    end
  end

  describe '#openit' do
    it 'sets closed_at to nil and return the result and the channel' do
      subject.stub(:update).with('37', {closed_at: nil}).and_return [true, 'opened channel']
      subject.openit('37').should eq [true, 'opened channel']
    end
  end

  describe '#closeit' do
    it 'sets closed_at to Time.now and return the result and the channel' do
      freeze_time
      subject.stub(:update).with('37', {closed_at: Time.now}).and_return [true, 'closed channel']
      subject.closeit('37').should eq [true, 'closed channel']
    end
  end
end