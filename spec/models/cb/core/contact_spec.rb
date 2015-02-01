require 'spec_helper'

describe CB::Core::Contact do

  subject {CB::Core::Contact.new}

  describe 'relations' do
    it { should have_many(:channel_subscriptions).class_name('CB::Core::ChannelSubscription').with_foreign_key(:contact_id).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:email).scoped_to(:owner_id) }
    it { should validate_presence_of :email }
    it { should_not allow_value('asdfjkl').for(:email) }
    it { should allow_value('asdfjkl@qsd.com').for(:email) }
  end
end