require 'spec_helper'

describe CB::Core::Publication do

  it 'persists and supports mass assignment' do
    now = freeze_time

    content = FactoryGirl.create(:user_content)
    content.reload.publications_count.should eq 0

    publication = CB::Core::Publication.create(channel_id: 42, content_id: content.id, url_alias: 'url_alias', provider_ref: 'RXE908')

    publication.published_at.to_i.should             eq now.to_i
    publication.channel_id.should                    eq 42
    publication.content_id.should                    eq content.id
    publication.url_alias.should                     eq 'url_alias'
    publication.expire_at.should                     be_nil
    publication.last_failed_unpublish_at.should      be_nil
    publication.last_failed_unpublish_message.should be_nil
    publication.failed_unpublish_count.should        eq 0
    publication.provider_ref.should                  eq 'RXE908'
    publication.deleted_at.should                    be_nil

    content.reload.publications_count.should eq 1
  end

  it { should belong_to(:channel).class_name('CB::Core::Channel') }
  it { should belong_to(:content).class_name('CB::Core::Content') }

  it { should validate_uniqueness_of(:channel_id).scoped_to(:content_id) }

  describe 'scopes' do
    describe 'default scope' do
      it 'excludes deleted publications' do
        query = CB::Core::Publication.all
        query.default_scoped.should   be_true
        query.scope_for_create.should eq({'deleted_at' => nil})
      end
    end
    it '#with_content' do
      query = CB::Core::Publication.with_content
      query.includes_values.first.should eq :content
    end

    it '#with_content_and_type' do
      query = CB::Core::Publication.with_content_and_type
      query.includes_values.first.should eq({content: :content_type})
    end

    it '#from_channel' do
      criteria = CB::Core::Publication.from_channel(OpenStruct.new(id: 43)).where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'channel_id'
      criteria.right.should     eq 43
    end
    it '#of_content_type' do
      query = CB::Core::Publication.of_content_type(OpenStruct.new(id: 43))
      query.joins_values.first.should eq :content
      query.where_values.first.should eq 'contents.content_type_id = 43'
    end
    it '#with_url_alias' do
      criteria = CB::Core::Publication.with_url_alias('my-alias').where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'url_alias'
      criteria.right.should     eq 'my-alias'
    end
    it '#recent sorts the publications by published_at DESC' do
      CB::Core::Publication.recent.order_values.should eq ['published_at DESC']
    end
    it '#expired_to_delete returns publications with passed expire_at and less than 3 failed_unpublish_count and eager_loads owner' do
      now = freeze_time

      query = CB::Core::Publication.expired_to_delete

      query.includes_values.first.should eq :user

      query.where_values.first.should  eq "expire_at <= '#{I18n.l(Time.now, format: :sql)}'"
      query.where_values.second.should eq 'failed_unpublish_count < 3'
    end

    it '#owned_by it returns publications whose content is owned by the given user' do
      query = CB::Core::Publication.owned_by(OpenStruct.new(id: 43))
      query.joins_values.first.should eq :content
      query.where_values.first.should eq 'contents.owner_id = 43'
    end
  end

  describe 'virtual accessors' do
    before do
      @publication = CB::Core::Publication.new
    end
    context 'given a publication in a website channel' do
      before do
        @channel = CB::Core::WebsiteChannel.new(url_prefix: 'chanprefix')
        @publication.channel = @channel
        @publication.url_alias = 'publi-slug'
      end
      it '#permalink returns the url to CB.me website for this channel and publication permalink' do
        @publication.permalink.should eq 'http://chanprefix.contentbird.me/permalink/publi-slug'
      end
    end
    context 'given a publication in a social channel' do
      before do
        @channel = CB::Core::SocialChannel.new(url_prefix: 'chanprefix')
        @publication.url_alias = 'publi-slug'
      end
      it '#permalink returns the url to CB.me website for this channel and publication permalink' do
        @publication.permalink(@channel).should eq 'http://chanprefix.contentbird.me/p/publi-slug'
      end
    end
    context 'given a publication in a api channel' do
      before do
        @channel = CB::Core::APIChannel.new
      end
      it '#permalink returns #' do
        @publication.permalink(@channel).should eq '#'
      end
    end
  end

  describe '#generate_url_alias' do
    it 'generated a different url safe alias each time' do
      first_alias   = CB::Core::Publication.generate_url_alias
      second_alias  = CB::Core::Publication.generate_url_alias

      first_alias.should_not  eq second_alias
      first_alias.should      eq URI::encode(first_alias)
      second_alias.should     eq URI::encode(second_alias)
    end
    it 'generates a new url_alias if the generated one already exists' do
      CB::Core::Publication.stub(:exists?).and_return(true, false)

      CB::Core::Publication.generate_url_alias.should_not eq 'existing_alias'
    end
  end

  describe 'soft deletion' do
    describe '#soft_delete' do
      before do
        @now = freeze_time
        @pub = CB::Core::Publication.create(channel_id:                    12,
                                            content_id:                    42,
                                            expire_at:                     1.day.ago,
                                            failed_unpublish_count:        2,
                                            last_failed_unpublish_message: 'bad credentials',
                                            last_failed_unpublish_at:      2.minutes.ago)
      end
      it "sets deleted_at to now, saves, updates the content's counter cache and returns true" do
        CB::Core::Content.should_receive(:reset_counters).with(42, :publications)
        @pub.soft_delete.should                   be_true
        @pub.deleted_at.to_i.should               eq @now.to_i

        @pub.reload

        @pub.deleted_at.to_i.should               eq @now.to_i
        @pub.expire_at.should                     be_nil
        @pub.failed_unpublish_count.should        eq 0
        @pub.last_failed_unpublish_message.should be_nil
        @pub.last_failed_unpublish_at.should      be_nil
      end
      it 'returns false and changes nothing if it could not save the change' do
        CB::Core::Content.should_receive(:reset_counters).with(42, :publications).never
        @pub.stub(:valid?).and_return   false
        @pub.soft_delete.should         be_false
        @pub.deleted_at.should          be_nil

        @pub.reload

        @pub.deleted_at.should                    be_nil
        @pub.expire_at.to_i.should                eq 1.day.ago.to_i
        @pub.failed_unpublish_count.should        eq 2
        @pub.last_failed_unpublish_message.should eq 'bad credentials'
        @pub.last_failed_unpublish_at.to_i.should eq 2.minutes.ago.to_i
      end
    end

    describe '#undelete' do
      before do
        freeze_time
        @pub = CB::Core::Publication.create(channel_id: 12, content_id: 42, deleted_at: 2.days.ago)
      end
      it "sets deleted_at to nil, saves, updates the content's counter cache and returns true" do
        CB::Core::Content.should_receive(:reset_counters).with(42, :publications)
        @pub.undelete.should                be_true
        @pub.deleted_at.should              be_nil
        @pub.reload.deleted_at.should       be_nil
      end
      it 'returns false and changes nothing if it could not save the change' do
        CB::Core::Content.should_receive(:reset_counters).with(42, :publications).never
        @pub.stub(:valid?).and_return false
        @pub.undelete.should                 be_false
        @pub.deleted_at.to_i.should          eq 2.days.ago.to_i
        @pub.reload.deleted_at.to_i.should   eq 2.days.ago.to_i
      end
    end

    describe '#deleted?' do
      it 'returns true if deleted_at is present and false if not' do
        pub = CB::Core::Publication.new
        pub.should_not be_deleted

        pub.deleted_at = Time.now
        pub.should be_deleted
      end
    end

    describe '#first_deleted_for_channel_and_content' do
      it 'returns the first deleted publication for the given channel and content' do
        the_one = CB::Core::Publication.create!(content_id: 12, channel_id: 42)
        deleted_other_content = CB::Core::Publication.create!(content_id: 37, channel_id: 42, deleted_at: 1.month.ago)
        deleted_other_channel = CB::Core::Publication.create!(content_id: 12, channel_id: 63, deleted_at: 1.month.ago)
        channel_double = OpenStruct.new(id: 42)
        content_double = OpenStruct.new(id: 12)

        CB::Core::Publication.first_deleted_for_channel_and_content(channel_double, content_double).should be_nil

        the_one.update_attribute(:deleted_at, 1.minute.ago)

        CB::Core::Publication.first_deleted_for_channel_and_content(channel_double, content_double).should eq the_one
      end
    end
  end

  describe '#reset_provider_ref' do
    before do
      @publi = CB::Core::Publication.create(content_id: 12, channel_id: 42, provider_ref: 'tweet-id-hey')
    end
    it 'sets the provider ref to the given value or nil, saves the publication, and returns true if success' do
      @publi.reset_provider_ref.should  be_true
      @publi.provider_ref.should        be_nil
      @publi.reload.provider_ref.should be_nil

      @publi.reset_provider_ref('new-tweet-id').should  be_true
      @publi.provider_ref.should        eq 'new-tweet-id'
      @publi.reload.provider_ref.should eq 'new-tweet-id'
    end
    it 'returns false if save is impossible' do
      @publi.stub(:valid?).and_return(false)
      @publi.reset_provider_ref.should  be_false
      @publi.provider_ref.should        eq 'tweet-id-hey'
      @publi.reload.provider_ref.should eq 'tweet-id-hey'
    end
  end

end