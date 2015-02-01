describe CB::Manage::APIChannel do
  let(:user) {u = CB::Core::User.new ; u.id = 12; u}
  subject { CB::Manage::APIChannel.new(user) }

  describe '#build_new' do
    it 'returns channel populated with given params' do
      CB::Core::APIChannel.stub(:new).with({name: 'my api', url_prefix: 'my-api'}).and_return('an api channel')

      subject.build_new(name: 'my api', url_prefix: 'my-api').should eq 'an api channel'
    end
  end
end