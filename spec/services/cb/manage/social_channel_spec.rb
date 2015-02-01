describe CB::Manage::SocialChannel do
  let(:user) {u = CB::Core::User.new ; u.id = 12; u}
  subject { CB::Manage::SocialChannel.new(user) }

  describe '#build_new' do
    context 'given twitter oauth hash' do
      before do
        @oauth_hash =  {provider: 'twitter', info: {nickname: 'nna_test'}, credentials: { token:  'provided token', secret: 'provided secret' } }
      end
      it 'returns a channel with name and url_prefix prepopulated according to user\'s nickname from twitter oauth_info' do
        CB::Core::SocialChannel.stub(:new).with(provider: 'twitter', name: '@nna_test', url_prefix: 'at-nna-test').and_return(channel_double = double('a twitter social channel'))
        channel_double.should_receive(:provider_oauth_token=).with('provided token')
        channel_double.should_receive(:provider_oauth_secret=).with('provided secret')

        subject.build_new(oauth: @oauth_hash).should eq channel_double
      end
    end

    context 'given gplus oauth hash' do
      before do
        @oauth_hash =  {provider: 'googleplus', info: {name: 'John Doe'}, credentials: { token:  'provided token'} }
      end
      it 'returns channel with name and url_prefix prepopulated according to user\'s name from gplus oauth_info' do
        CB::Core::SocialChannel.stub(:new).with(provider: 'googleplus', name: '+John Doe', url_prefix: 'gp-john-doe').and_return(channel_double = double('a gplus social channel'))
        channel_double.should_receive(:provider_oauth_token=).with('provided token')
        channel_double.should_receive(:provider_oauth_secret=).with(nil)

        subject.build_new(oauth: @oauth_hash).should eq channel_double
      end
    end

    context 'given linkedin oauth hash' do
      before do
        @oauth_hash =  {provider: 'linkedin', info: {nickname: 'John Doe'}, credentials: { token:  'provided token', secret: 'provided secret'} }
      end
      it 'returns channel with name and url_prefix prepopulated according to user\'s nickname from linkedin oauth_info' do
        CB::Core::SocialChannel.stub(:new).with(provider: 'linkedin', name: 'in-John Doe', url_prefix: 'in-john-doe').and_return(channel_double = double('a linkedin social channel'))
        channel_double.should_receive(:provider_oauth_token=).with('provided token')
        channel_double.should_receive(:provider_oauth_secret=).with('provided secret')

        subject.build_new(oauth: @oauth_hash).should eq channel_double
      end
    end

    context 'given facebook oauth hash' do
      before do
        @oauth_hash =  {provider: 'facebook', info: {nickname: 'john.doe'}, credentials: { token:  'provided token', secret: 'provided secret'} }
      end
      it 'returns channel with name and url_prefix prepopulated according to user\'s nickname from linkedin oauth_info' do
        CB::Core::SocialChannel.stub(:new).with(provider: 'facebook', name: 'fb-john.doe', url_prefix: 'fb-john-doe').and_return(channel_double = double('a facebook social channel'))
        channel_double.should_receive(:provider_oauth_token=).with('provided token')
        channel_double.should_receive(:provider_oauth_secret=).with('provided secret')

        subject.build_new(oauth: @oauth_hash).should eq channel_double
      end
    end

    it 'returns channel populated with given params' do
      CB::Core::SocialChannel.stub(:new).with({provider: 'some', name: 'my twitter', url_prefix: 'twit'}).and_return('a social channel')

      subject.build_new(provider: 'some', name: 'my twitter', url_prefix: 'twit').should eq 'a social channel'
    end
  end

  describe '#check_credentials' do
    before do
      subject.stub(:find).with('37').and_return(@channel_double = double('channel', provider_class: CB::Publish::Twitter))
    end

    it 'finds the channel and asks its provider publisher class to validate the credentials' do
      CB::Publish::Twitter.stub(:new).with(@channel_double).and_return(twitter_publisher = double('twitter publisher'))
      twitter_publisher.stub(:check_credentials).and_return([true, {credentials: 'credentials'}])

      subject.check_credentials('37').should eq [true, {credentials: 'credentials'}]
    end
  end

  describe '#update_credentials' do
    context 'given twitter oauth hash' do
      before do
        @oauth_hash =  {provider: 'twitter', info: {nickname: 'nna_test'}, credentials: { token:  'provided token', secret: 'provided secret' } }
        subject.stub(:find).with('37').and_return(@channel_double = double('social channel'))
        @channel_double.should_receive(:provider_oauth_token=).with('provided token')
        @channel_double.should_receive(:provider_oauth_secret=).with('provided secret')
      end

      it 'finds the channel matching the given id, updates token and secret according to the oauth hash, saves the channel, and returns a splat' do
        @channel_double.should_receive(:save).and_return true

        subject.update_credentials('37', @oauth_hash).should eq [true, @channel_double]
      end

      it 'returns false and the channel if credentials update fails' do
        @channel_double.should_receive(:save).and_return false

        subject.update_credentials('37', @oauth_hash).should eq [false, @channel_double]
      end
    end
  end
end