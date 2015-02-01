require "spec_helper"
require "cb/core/channel"

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before  { ActionView::Template.any_instance.stub(:render).and_return('body') } #Avoid rendering complex views

  describe '#invite_lead' do
    subject { UserMailer.invite_lead(CB::Core::Lead.new(email: 'somelead@email.fr', token: 'token')) }
    it      { should have_header("X-SMTPAPI", '{"category": "invite_lead"}') }
    it      { should be_delivered_to('somelead@email.fr') }
  end

  describe '#invitation' do
    subject { UserMailer.invitation(CB::Core::User.new(nest_name: 'your_friend'), email: 'invited@email.io') }
    it      { should have_header("X-SMTPAPI", '{"category": "invitation"}') }
    it      { should be_delivered_to('invited@email.io') }
  end

  describe '#email_publication' do
    before do
      @publisher = FactoryGirl.create(:user)
      @channel   = CB::Core::MessagingChannel.create!(owner_id: @publisher.id, name: 'my email channel', provider: 'email')
      @channel.contacts.create!(owner_id: @publisher.id, email: 'sub1@gmail.com')
      @channel.contacts.create!(owner_id: @publisher.id, email: 'sub2@gmail.com')
      @content = FactoryGirl.create(:link_content, owner: @publisher)
      published, @publication, whatever = CB::Manage::Publication.new(@publisher).publish(@content.id, @channel.id)
      @mailer = UserMailer.email_publication(@publication)
    end

    it 'sends a properly formated publication email' do
      @mailer.should have_header("X-SMTPAPI", '{"category": "email_publication"}')
      @mailer.should be_delivered_to([@publisher.email, 'sub1@gmail.com', 'sub2@gmail.com'])
    end
  end
end