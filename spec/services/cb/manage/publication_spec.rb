require 'spec_helper'

describe CB::Manage::Publication do
  let(:user) {u = CB::Core::User.new ; u.id = 12; u}
  subject    { CB::Manage::Publication.new(user) }

  before do
    CB::Manage::Content.stub(:new).with(user).and_return(@content_service = double('content service'))
    CB::Manage::Channel.stub(:new).with(user).and_return(@channel_service = double('channel service'))
  end

  describe '#initialize' do
    it 'stores the passed user' do
      subject.user.should eq user
    end
  end

  describe '#find' do
    it 'finds the publication beloging to the user and matching the given id' do
      CB::Core::Publication.stub(:owned_by).with(user).and_return(readonly_publications = double('readonly user publications'))
      readonly_publications.stub(:readonly).with(false).and_return(user_publications = double('user publications'))
      user_publications.stub(:find).with('37').and_return 'the wanted publication'

      subject.find('37').should eq 'the wanted publication'
    end
  end

  describe '#list' do
    it 'asks the content service for the given content, and returns its publications hashed by channel_id' do
      @channel_service.stub(:list).and_return [ chan1=OpenStruct.new(id:12),
                                                chan2=OpenStruct.new(id:42),
                                                chan3=OpenStruct.new(id:74) ]
      @content_service.stub(:find).with('42').and_return(content = double('content'))
      content.stub(:publications_by_channel).and_return({'74' => (pub3=double), '42' => (pub2=double)})
      subject.list('42').should eq({chan1 => nil, chan2 => pub2, chan3 => pub3})
    end
  end

  describe '#list_for_channel' do
    it 'returns recent publications for this channel, with content and content_type eager loaded' do
      CB::Core::Publication.should_receive_in_any_order(:recent, {from_channel: 'my_channel'})
                           .stub(:with_content_and_type)
                           .and_return ['two', 'publications']

      subject.list_for_channel('my_channel').should eq ['two', 'publications']
    end
  end

  describe '#publish' do
    before do
      @content_service.stub(:find).with('37').and_return(@content = OpenStruct.new(slug: 'content-slug', content_type: 'my content_type'))
    end

    context 'given a website channel' do
      before do
        @channel_service.stub(:find).with('42').and_return(@channel = CB::Core::WebsiteChannel.new)
      end

      context 'given the content already has a deleted publication for this channel' do
        before do
          CB::Core::Publication.stub(:first_deleted_for_channel_and_content)
                  .with(@channel, @content)
                  .and_return(@deleted_publication = double('deleted publication', persisted?: true, content: @content, deleted?: false))
        end
        it 'creates a new publication with given content and channel matching given ids and return publication' do
          @deleted_publication.should_receive(:undelete).and_return(true)
          @channel.should_receive(:create_display_section_for_type_if_none).with('my content_type').and_return(false)

          subject.publish('37', '42').should eq [true, @deleted_publication, false]
        end
      end

      context 'given the content has NO deleted publication for this channel' do
        before do
          CB::Core::Publication.stub(:first_deleted_for_channel_and_content)
                  .with(@channel, @content)
                  .and_return(nil)
        end
        it 'creates a new publication with given content and channel matching given ids and return publication' do
          CB::Core::Publication.stub(:create)
                               .with(content: @content, channel: @channel, url_alias: 'content-slug')
                               .and_return(pub_double = double('publication', persisted?: true, content: @content, deleted?: false))
          @channel.should_receive(:create_display_section_for_type_if_none).with('my content_type').and_return(true)

          subject.publish('37', '42').should eq [true, pub_double, true]
        end
      end

    end

    context 'given a social channel' do
      before do
        @channel_service.stub(:find).with('42').and_return(@channel = CB::Core::SocialChannel.new(provider: 'twitter'))
      end

      context 'given the content already has a deleted publication for this channel' do
        before do
          CB::Core::Publication.stub(:first_deleted_for_channel_and_content)
                  .with(@channel, @content)
                  .and_return(@deleted_publication = double('deleted publication', persisted?: true, content: @content, deleted?: false))
          @deleted_publication.should_receive(:undelete).and_return(true)
          CB::Publish::Twitter.stub(:new).with(@channel).and_return(@twitter_double = double('twitter service'))
        end

        it 'undeletes the publication with an url_alias, does NOT publish to social provider, and return publication' do
          @twitter_double.should_receive(:publish).with(@deleted_publication).and_return([true, 'published_tweet_id'])
          subject.publish('37', '42').should eq [true, @deleted_publication, false]
        end

        context 'given social publication fails by social provider' do
          before do
            @twitter_double.should_receive(:publish).with(@deleted_publication).and_return([false, nil])
          end

          it 'soft deletes the publication again and returns false' do
            @deleted_publication.should_receive(:soft_delete)
            @deleted_publication.stub(:deleted?).and_return(true)
            subject.publish('37', '42').should eq [false, @deleted_publication, false]
          end
        end
      end

      context 'given the content has NO deleted publication for this channel' do
        before do
          CB::Core::Publication.stub(:first_deleted_for_channel_and_content)
                  .with(@channel, @content)
                  .and_return(nil)
          CB::Core::Publication.stub(:generate_url_alias).and_return 'generated_url_alias'
          CB::Core::Publication.stub(:create).with(content: @content, channel: @channel, url_alias: 'generated_url_alias').and_return(@pub_double = double('publication', persisted?: true, content: @content, deleted?: false))

          CB::Publish::Twitter.stub(:new).with(@channel).and_return(@twitter_double = double('twitter service'))
        end

        it 'creates a new publication with an url_alias, publish to social provider, store the provider ref of publication and return publication' do
          @twitter_double.should_receive(:publish).with(@pub_double).and_return([true, 'published_tweet_id'])

          subject.publish('37', '42').should eq [true, @pub_double, false]
        end

        context 'given social publication fails by social provider' do
          before do
            @twitter_double.should_receive(:publish).with(@pub_double).and_return([false, nil])
          end

          it 'destroys the publication and returns false' do
            @pub_double.should_receive(:destroy)
            @pub_double.stub(:persisted?).and_return(false)
            subject.publish('37', '42').should eq [false, @pub_double, false]
          end
        end
      end

    end
  end

  describe '#unpublish' do
    before do
      CB::Core::Publication.stub(:find).with('37').and_return(@pub_double = double('publication'))
    end
    context 'given service user is owner' do
      before do
        @pub_double.stub(:content).and_return(double('content', owner_id: user.id, reload: true))
      end

      context 'given a website channel' do
        before do
          @pub_double.stub(:channel).and_return(@channel = CB::Core::WebsiteChannel.new)
        end
        it 'destroys publication on CB and returns true' do
          @pub_double.should_receive(:soft_delete).and_return true

          subject.unpublish('37').should eq [true, @pub_double, false]
        end
        it 'returns false if publication removal fails' do
          @pub_double.should_receive(:soft_delete).and_return false

          subject.unpublish('37').should eq [false, @pub_double, false]
        end
      end

      context 'given a social channel' do
        before do
          @pub_double.stub(:channel).and_return(@channel = CB::Core::SocialChannel.new(provider: 'twitter'))
          CB::Publish::Twitter.stub(:new).with(@channel).and_return(@twitter_double = double('twitter service'))
        end
        it 'destroys publication on twitter, destroys publication on CB and returns true' do
          @twitter_double.should_receive(:unpublish).with(@pub_double).and_return([true, nil, false])
          @pub_double.should_receive(:soft_delete).and_return true

          subject.unpublish('37').should eq [true, @pub_double, false]
        end

        it 'if removal from twitter fails it updates the unpublish error fields on the publication model and returns false' do
          now = freeze_time
          @pub_double.stub(:failed_unpublish_count).and_return(1)
          @twitter_double.should_receive(:unpublish).with(@pub_double).and_return([false, {message: 'something'}, false])
          @pub_double.should_receive(:update_attributes).with(failed_unpublish_count: 2, last_failed_unpublish_at: now, last_failed_unpublish_message: 'something')
          @pub_double.should_receive(:soft_delete).never

          subject.unpublish('37').should eq [false, {message: 'something'}, false]
        end
      end

    end
    context 'given service user is not owner' do
      before do
        @pub_double.stub(:content).and_return(double('content', owner_id: user.id+1))
      end
      it 'does not destroy publication' do
        @pub_double.should_not_receive(:soft_delete)

        subject.unpublish('37').should eq [false, @pub_double, false]
      end
    end
  end

  describe '#set_expiration' do
    before do
      @now = freeze_time
      subject.stub(:find).with('37').and_return(@pub_double = double('publication'))
    end
    context 'given expire_in param is set to "never"' do
      it 'finds and update the publication model by setting expired_at following given expire_in parameter' do
        @pub_double.should_receive(:update_attribute).with(:expire_at, nil).and_return(true)
        @pub_double.stub(:expire_at).and_return(nil)
        subject.set_expiration('37', 'never').should eq [true, expire_at: nil]
      end
    end
    context 'given expire_in param is set to "day"' do
      it 'finds and update the publication model by setting expired_at following given expire_in parameter' do
        @pub_double.should_receive(:update_attribute).with(:expire_at, 1.day.from_now).and_return(true)
        @pub_double.stub(:expire_at).and_return(1.day.from_now)
        subject.set_expiration('37', 'day').should eq [true, expire_at: 1.day.from_now]
      end
    end
    context 'given expire_in param is set to "week"' do
      it 'finds and update the publication model by setting expired_at following given expire_in parameter' do
        @pub_double.should_receive(:update_attribute).with(:expire_at, 1.week.from_now).and_return(true)
        @pub_double.stub(:expire_at).and_return(1.week.from_now)
        subject.set_expiration('37', 'week').should eq [true, expire_at: 1.week.from_now]
      end
    end
    context 'given expire_in param is set to "month"' do
      it 'finds and update the publication model by setting expired_at following given expire_in parameter' do
        @pub_double.should_receive(:update_attribute).with(:expire_at, 1.month.from_now).and_return(true)
        @pub_double.stub(:expire_at).and_return(1.month.from_now)
        subject.set_expiration('37', 'month').should eq [true, expire_at: 1.month.from_now]
      end
    end
    context 'given expire_in param is set to garbage' do
      it 'returns false and a message explaining the param was wrong' do
        @pub_double.should_receive(:update_attribute).never
        subject.set_expiration('37', 'garbage').should eq [false, error: {msg: 'wrong expire limit parameter'}]
      end
    end
    context 'given publication update fails' do
      it 'returns false and a message explaining the update failed' do
        @pub_double.should_receive(:update_attribute).with(:expire_at, 1.day.from_now).and_return(false)
        subject.set_expiration('37', 'day').should eq [false, error: {msg: 'Could not update expiration date'}]
      end
    end
  end
end