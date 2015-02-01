require 'spec_helper'

describe CB::Core::User do

  describe 'persistence' do
    it 'persists and supports mass assignment' do
      user = CB::Core::User.create(nest_name: 'someguy', email: 'some@guy.io', password: 'somepass', password_confirmation: 'somepass')
      user.nest_name.should eq 'someguy'
      user.email.should     eq 'some@guy.io'
      user.locale.should    be_nil
      user.should_not       be_advanced_user
      user.should_not       be_platform_user
    end
  end

  describe 'associations' do
    it { should have_many(:own_content_types).class_name('CB::Core::ContentType').with_foreign_key(:owner_id).dependent(:destroy) }
    it { should have_many(:contents).class_name('CB::Core::Content').with_foreign_key(:owner_id) }
    it { should have_many(:channels).class_name('CB::Core::Channel').with_foreign_key(:owner_id).dependent(:destroy) }
    describe '#content_types' do
      it 'returns content types owned  or used by user' do
        owner = FactoryGirl.create(:user)
        user  = FactoryGirl.create(:user)
        content_type = FactoryGirl.build(:composite_type)
        content_type.owner = owner
        content_type.save!

        user.content_types << content_type
        user.save!

        owner.content_types.should eq [content_type]
        content_type.owner.should  eq owner
        user.content_types.should  eq [content_type]
      end
    end
  end

  describe 'validations' do
    it 'validates email and nest_name are present and unique' do
      previous_user = CB::Core::User.create(email: 'my@email.com', nest_name: 'my_nest', password: '12345678', password_confirmation: '12345678')
      user          = CB::Core::User.new(nest_name: 'some_nest', password: '12345678', password_confirmation: '12345678')
      user.should_not be_valid
      user.email = 'my@email.com'
      user.should_not be_valid
      user.email = 'some@email.com'
      user.should be_valid
      user.nest_name = nil
      user.should_not be_valid
      user.nest_name = 'my_nest'
      user.should_not be_valid
    end
  end

  describe 'virtual accessors' do
    it 'has a token' do
      u = CB::Core::User.new
      expect{u.token='lariflette'}.to change{u.token}.from(nil).to('lariflette')
    end

    it '#number_of_channels_by_provider counts the social channels owned by the user, grouped by provider' do
      user = FactoryGirl.create(:user)
      CB::Core::WebsiteChannel.create!(owner_id: user.id, name: 'website', url_prefix: 'website')
      CB::Core::SocialChannel.create!(owner_id: user.id, name: 'ln feed', url_prefix: 'ln', provider: 'linkedin')
      CB::Core::SocialChannel.create!(owner_id: user.id, name: 'tw feed', url_prefix: 'tw', provider: 'twitter')

      result = user.number_of_channels_by_provider

      result.size.should        eq 2
      result['twitter'].should  eq 1
      result['linkedin'].should eq 1
    end

    it '#advanced? returns true if user is platform user, or admin or advanced_user' do
      u = CB::Core::User.new
      u.should_not be_advanced

      u.admin = true
      u.should be_advanced

      u.admin         = false
      u.platform_user = true
      u.should be_advanced

      u.platform_user = false
      u.advanced_user = true
      u.should be_advanced
    end

    it '#first_website_channel returns teh first website channel owned by the user' do
      user = FactoryGirl.create(:user)

      user.first_website_channel.should be_nil

      CB::Core::SocialChannel.create(owner_id: user.id, name: 'ln feed', url_prefix: 'ln', provider: 'linkedin')

      user.first_website_channel.should be_nil

      channel = CB::Core::WebsiteChannel.create!(owner_id: user.id, name: 'website', url_prefix: 'website')
      CB::Core::WebsiteChannel.create!(owner_id: user.id, name: 'website2', url_prefix: 'website2')

      user.first_website_channel.should eq channel
    end

    it 'remembers the last announcement click' do
      user = FactoryGirl.create(:user)

      user.announcement_clicked?('my_news').should       be_false

      user.announcement_clicked!('my_news')
      user.announcement_clicked?('my_news').should       be_true

      user.reload
      user.announcement_clicked?('my_news').should       be_true
      user.announcement_clicked?('my_other_news').should be_false
    end
  end

end
