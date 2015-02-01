require "spec_helper"

describe CB::InMail::Manager do
  let(:sender_user) { FactoryGirl.build :user }
  let(:email)  { FactoryGirl.build :email, from: sender_user.email }

  subject { CB::InMail::Manager.new(email) }

  describe '#manage' do

    context 'given sender is an existing user' do
      before do
        sender_user.save!
      end

      context 'email is sent to valid recipient address' do
        before do
          subject.stub(:one_valid_recipient?).and_return true
        end

        it 'parses the mail and creates deduced content' do
          CB::InMail::Parser.stub(:new).with(email).and_return        email_parser    = double('email_parser')
          CB::Manage::Content.stub(:new).with(sender_user).and_return content_service = double('content_service')

          link_type = FactoryGirl.build :link_type
          email_parser.should_receive(:parse).and_return [link_type, 'params']
          content_service.should_receive(:create).with(link_type, 'params').and_return [true, 'content']

          subject.manage.should eq [true, 'content']
        end
      end

      context 'email is sent to invalid recipient address' do
        before do
          subject.stub(:one_valid_recipient?).and_return false
        end

        it 'nor parses nor create content' do
          CB::InMail::Parser.should_receive(:new).never
          CB::Manage::Content.should_receive(:new).never

          subject.manage.should eq [false, nil]
        end
      end
    end

  end

  describe 'one_valid_recipient?' do
    context 'given one recipient' do
      it 'knows which adresses are valid' do
        subject.stub(:recipients_email).and_return ['toto@toto.com'];       subject.one_valid_recipient?.should be_false
        subject.stub(:recipients_email).and_return ['nna@contentbird.com']; subject.one_valid_recipient?.should be_false
        subject.stub(:recipients_email).and_return ['adrient@cbird.me'];    subject.one_valid_recipient?.should be_false
        subject.stub(:recipients_email).and_return ['me@cbird.me'];         subject.one_valid_recipient?.should be_true
        subject.stub(:recipients_email).and_return ['me@contentbird.me'];   subject.one_valid_recipient?.should be_true
      end
    end
    context 'given many recipients' do
      it 'returns true if one is valid' do
        subject.stub(:recipients_email).and_return ['toto@toto.com', 'nna@contentbird.com'] ; subject.one_valid_recipient?.should be_false
        subject.stub(:recipients_email).and_return ['toto@toto.com',     'me@cbird.me']     ; subject.one_valid_recipient?.should be_true
        subject.stub(:recipients_email).and_return ['me@contentbird.me', 'me@cbird.me']     ; subject.one_valid_recipient?.should be_true
      end
    end
  end
end