require 'spec_helper'

describe CB::Core::Channel do

  subject {CB::Core::Channel.new}

  it 'generates new access_token, persists and supports mass assignment' do
    SecureRandom.stub(:hex).and_return('generated_token')
    css_fixture_file = File.open(File.join(Rails.root, '/spec/fixtures/files/channel.css'))
    channel = CB::Core::Channel.create(name: 'Channel Name', url_prefix: 'chan', owner_id: 3, css: css_fixture_file, baseline: 'My baseline', cover: 'my_cover.jpg')
    channel.reload

    channel.closed_at.should    eq nil
    channel.name.should         eq 'Channel Name'
    channel.url_prefix.should   eq 'chan'
    channel.owner_id.should     eq 3
    channel.access_token.should eq 'generated_token'
    channel.css.url.should      eq "/app/storage_mock/channel/channels/css/#{channel.id}/channel.css"
    channel.baseline.should     eq 'My baseline'
    channel.cover.should        eq 'my_cover.jpg'
  end

  describe 'validations' do
    it { should validate_presence_of   :name }
    it { should validate_presence_of   :url_prefix }
    it 'ensures exclusion of certain url_prefix' do
      subject.stub(:excluded_url_prefixes).and_return ['www', 'blog']
      should ensure_exclusion_of(:url_prefix).in_array(['www', 'blog'])
    end
  end

  describe 'relations' do
    it { should belong_to(:owner).class_name('CB::Core::User') }
    it { should have_many(:sections).dependent(:destroy) }
    it { should have_many(:publications).dependent(:destroy) }
    it { should have_many(:published_contents).through(:publications) }

    it { should accept_nested_attributes_for(:sections).allow_destroy(true) }
  end

  describe 'scopes' do
    it '#opened returns channels with no closed_at date' do
      criteria = CB::Core::Channel.opened.where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'closed_at'
      criteria.right.should     eq nil
    end

    it '#for_prefix returns channels where url_prefix matches the given prefix' do
      criteria = CB::Core::Channel.for_prefix('my-prefix').where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'url_prefix'
      criteria.right.should     eq 'my-prefix'
    end

    it '#for_credentials returns channels where id and access_token matches the given ones' do
      query = CB::Core::Channel.for_credentials('my-id', 'my-token').where_values

      id_criteria = query.first
      id_criteria.class.should     eq Arel::Nodes::Equality
      id_criteria.left.name.should eq 'id'
      id_criteria.right.should     eq 'my-id'

      token_criteria = query.second
      token_criteria.class.should     eq Arel::Nodes::Equality
      token_criteria.left.name.should eq 'access_token'
      token_criteria.right.should     eq 'my-token'
    end

    it '#only_basic_info selects only id, access_token and type columns' do
      CB::Core::Channel.only_basic_info.select_values.should eq [:id, :access_token, :type]
    end

    it '#owned_by returns channels owned-by given user' do
      criteria = CB::Core::Channel.owned_by('the_id').where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'owner_id'
      criteria.right.should     eq 'the_id'
    end

  end

  describe 'accessors' do

    it '#closed? returns true if closed_at is set, false otherwise' do
      subject.closed?.should be_false
      subject.closed_at = 2.days.from_now
      subject.closed?.should be_true
    end

    it '#home_section returns the first section' do
      subject.stub(:sections).and_return(double('sections', first: 'my home section'))
      subject.home_section.should eq 'my home section'
    end

    it '#pretty_type returns a human readable version of the ugly namespaced type' do
      CB::Core::WebsiteChannel.new.pretty_type.should eq "Website"
    end

    it '#cover_url returns the full url for its cover' do
      CB::Core::Channel.new(cover: 'cover/mycover.jpg').cover_url.should eq '/app/storage_mock/channel/cover/mycover.jpg'
      CB::Core::Channel.new.cover_url.should be_nil
    end

    it '#web_url returns the url of the channel including the cb.me website domain' do
      with_constants :WEBSITE_DOMAIN => 'cb.me' do
        CB::Core::WebsiteChannel.new(url_prefix: 'my-chan').web_url.should eq 'my-chan.cb.me'
      end
    end

    it '#last_publication_at returns the published_at date of the latest publication for this channel' do
      freeze_time
      subject.stub(:publications).and_return(publications = double('publications'))
      publications.stub(:recent).and_return(recent_publications = double('recent publications'))
      recent_publications.stub(:first).and_return(OpenStruct.new(published_at: 23.hours.ago))

      subject.last_publication_at.should eq 23.hours.ago
    end
  end

  describe 'dynamic section creation' do
    it_should_behave_like "a channel who dynamically creates sections when publishing", CB::Core::WebsiteChannel
  end

  describe '#save_with_new_url_prefix' do
    before do
      @channel = CB::Core::WebsiteChannel.new(name: 'My channel', url_prefix: 'my-chan', owner_id: 37)
    end

    it 'saves the channel with the default url_prefix' do
      @channel.save_with_new_url_prefix

      @channel.should be_persisted
      @channel.url_prefix.should eq 'my-chan'
    end

    context 'given a channel with same url_prefix already exists' do
      before do
        CB::Core::WebsiteChannel.create! name: 'My channel',        url_prefix: 'my-chan',   owner_id: 37
        CB::Core::SocialChannel.create!  name: 'My second channel', url_prefix: 'my-chan-1', owner_id: 42, provider: 'twitter'
      end
      it 'saves the channel incrementing a counter at the end of the url prefix' do
        @channel.save_with_new_url_prefix

        @channel.should be_persisted
        @channel.url_prefix.should eq 'my-chan-2'
      end
    end
    context 'given cannot be saved for other reasons than the url_prefix already exists' do
      before do
        @channel.stub(:errors).and_return OpenStruct.new(messages: [name: ['can\'t be blank']])
      end
      it 'does not save the channel but avoids an infinite loop' do
        @channel.should_receive(:save).once

        @channel.save_with_new_url_prefix

        @channel.should_not be_persisted
      end
    end
  end

  describe '#generate_url_prefix' do
    it 'generates a different url prefix alias each time' do
      first_prefix   = CB::Core::Channel.generate_url_prefix
      second_prefix  = CB::Core::Channel.generate_url_prefix

      first_prefix.should_not  eq second_prefix
      first_prefix.should      eq URI::encode(first_prefix)
      second_prefix.should     eq URI::encode(second_prefix)
    end
    it 'generates a new url_prefix if the generated one already exists' do
      CB::Core::Channel.stub(:exists?).and_return(true, false)

      CB::Core::Channel.generate_url_prefix.should_not eq 'existing_alias'
    end
    it 'generates a SecureRandom urlsafe base64 downcased string' do
      SecureRandom.stub(:urlsafe_base64).with(8).and_return 'AZrt123-'
      CB::Core::Channel.generate_url_prefix.should eq 'azrt123-'
    end
  end

end