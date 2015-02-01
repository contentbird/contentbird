# require "spec_helper"

# describe "IncomingMailProcessor" do
#   let(:sender) { FactoryGirl.build :user }
#   let(:email)  { FactoryGirl.build :email, from: sender.email }

#   subject { IncomingMailProcessor }

#   describe '#process' do

#     context 'email is sent to valid recipient address' do
#       before do
#         subject.stub(:one_valid_recipient?).and_return true
#       end
#       context 'given sender is an existing user' do
#         before do
#           sender.save
#         end

#         it 'parses the mail and creates deduced content' do
#           CB::InMail::Parser.stub(:new).with(email).and_return   email_parser    = double('email_parser')
#           CB::Manage::Content.stub(:new).with(sender).and_return content_service = double('content_service')

#           link_type = FactoryGirl.build :link_type
#           email_parser.should_receive(:parse).and_return [link_type, 'params']
#           content_service.should_receive(:create).with(link_type, 'params').and_return [true, 'content']

#           subject.process(email).should eq [true, 'content']
#         end
#       end
#     end

#   end

#   describe 'one_valid_recipient?' do
#     context 'given one recipient' do
#       it 'knows which adresses are valid' do
#         subject.one_valid_recipient?(['toto@toto.com']).should       be_false
#         subject.one_valid_recipient?(['nna@contentbird.com']).should be_false
#         subject.one_valid_recipient?(['adrient@cbird.me']).should    be_false

#         subject.one_valid_recipient?(['me@cbird.me']).should         be_true
#         subject.one_valid_recipient?(['me@contentbird.me']).should   be_true
#       end
#     end
#     context 'given many recipients' do
#       it 'returns true if one is valid' do
#         subject.one_valid_recipient?(['toto@toto.com', 'nna@contentbird.com']).should be_false

#         subject.one_valid_recipient?(['toto@toto.com',     'me@cbird.me']).should     be_true
#         subject.one_valid_recipient?(['me@contentbird.me', 'me@cbird.me']).should     be_true
#       end
#     end
#   end
# end