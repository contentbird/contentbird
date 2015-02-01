require "spec_helper"
require "mail/outgoing_mail_interceptor"

TEST_EMAIL      = 'mon@adresse.com'
ENV["APP_NAME"] = 'mon_env'

describe "OutgoingMailInterceptor" do

  describe 'given single receiver email' do
    describe 'given no existing header' do
      before do
        header = double('header')
        header.stub("[]").with('X-SMTPAPI').and_return(nil)
        @message = double 'message', to: '["desti@nataire"]', subject: 'There was a time...', header: header
      end
      it 'should change the message to and the subject' do
        @message.should_receive(:to=).with('mon@adresse.com')
        @message.should_receive(:subject=).with('[mon_env]["desti@nataire"] There was a time...')
        OutgoingMailInterceptor.delivering_email @message
      end
    end
    describe 'given an existing header' do
      before do
        @header = double('header')

        header_hash = {"existing_key" => "existing_val"}
        header_hash.stub(:value).and_return(header_hash.to_json)
        @header.stub("[]").with('X-SMTPAPI').and_return(header_hash)

        @message = double 'message', to: '["desti@nataire"]', subject: 'There was a time...'
        @message.stub(:header).and_return(@header)
      end

      it "should change the message to and the subject" do
        @message.should_receive(:to=).with('mon@adresse.com')
        @message.should_receive(:subject=).with('[mon_env]["desti@nataire"] There was a time...')
        OutgoingMailInterceptor.delivering_email @message
      end
    end

  end

  describe 'given multiple receiver email' do
    before do
      @header = double('header')

      header_hash = {"to" => ["real1_nna@test.com","real2_pdu@test.com","real3_aaz@test.com"], "sub" => {"%first_name%" =>["nicolas","pierre","alex"], "%last_name%" => ["nardone","dupont","azli"]}}
      header_hash.stub(:value).and_return(header_hash.to_json)
      @header.stub("[]").with('X-SMTPAPI').and_return(header_hash)

      @message = double 'message', to: '["desti@nataire"]', subject: 'There was a time...'
      @message.stub(:header).and_return(@header)
    end

    it 'should change the message to and the subject' do
      @message.should_receive(:to=).with('mon@adresse.com')
      @message.should_receive(:subject=).with('[mon_env] [to: real1_nna@test.com real2_pdu@test.com] There was a time...')
      substituted_header = {"to" => ["mon@adresse.com","mon@adresse.com"], "sub" => {"%first_name%" =>["nicolas","pierre"], "%last_name%" => ["nardone","dupont"]}}
      @message.header["X-SMTPAPI"].should_receive(:value=).with(substituted_header.to_json)

      OutgoingMailInterceptor.delivering_email @message
    end
  end

end