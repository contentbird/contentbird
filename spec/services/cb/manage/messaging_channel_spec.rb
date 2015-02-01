describe CB::Manage::MessagingChannel do
  let(:user) { u = CB::Core::User.new ; u.id = 12; u  }
  subject    { CB::Manage::MessagingChannel.new(user) }

  describe '#build_new' do
    it 'returns channel populated with given params' do
      CB::Core::MessagingChannel.stub(:new).with({provider: 'email', name: 'my email list', url_prefix: 'le'}).and_return('a email channel')

      subject.build_new(provider: 'email', name: 'my email list', url_prefix: 'le').should eq 'a email channel'
    end
  end

  describe '#find' do
    it 'returns the messaging channel matching given key, owned by user, with subscriptions and contacts pre-loaded' do
      CB::Core::MessagingChannel.should_receive_in_any_order({owned_by: user}, {includes: {subscriptions: :contact}})
                                .should_receive(:find).with(47)
                                .and_return('my messaging channel')

      subject.find(47).should eq 'my messaging channel'
    end
  end

end