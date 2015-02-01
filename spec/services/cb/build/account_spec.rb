require 'spec_helper'
require 'cb/core/channel'

describe CB::Build::Account do

  let(:user) {u = CB::Core::User.new ; u.id = 12; u}
  subject    { CB::Build::Account.new(user) }

  describe '#initialize' do
    it 'stores the passed user' do
      subject.user.should eq user
    end
  end

  describe '#set_default_content_types_usages' do
    it 'add usages for every default content_type' do
      type1 = double('content type 1')
      type2 = double('content type 2')
      CB::Core::ContentType.stub(:usable_by_default).and_return([type1, type2])

      type1.should_receive(:add_usage_for_user).with(user)
      type2.should_receive(:add_usage_for_user).with(user)

      subject.set_default_content_types_usages
    end
  end

  describe '#create_default_website' do
    before do
      @user = FactoryGirl.create(:user, nest_name: 'adrien')
    end
    it 'adds a website channel to the user using the user nest_name for the url_prefix' do
      CB::Build::Account.new(@user).create_default_website

      @user.channels.size.should eq 1
      website = @user.channels.first
      website.is_a?(CB::Core::WebsiteChannel).should be_true
      website.url_prefix.should eq 'adrien'
      website.name.should eq 'My website'
    end

    it 'increments a counter as long as channels using the same url_prefix exist' do
      CB::Core::WebsiteChannel.create(url_prefix: 'adrien', name: 'some website', owner_id: 42)

      CB::Build::Account.new(@user).create_default_website

      @user.channels.size.should eq 1
      website = @user.channels.first
      website.is_a?(CB::Core::WebsiteChannel).should be_true
      website.url_prefix.should eq 'adrien-1'
      website.name.should eq 'My website'
    end
  end

end