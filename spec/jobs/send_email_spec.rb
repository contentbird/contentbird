require 'spec_helper'

describe SendEmail do
  describe "perform" do
    it 'sends email of the proper type, passing the relevant object as parameter, and optional args hash' do
      lead = CB::Core::Lead.create(email: 'some@email.com', token: 'token')
      CB::Core::Lead.stub(:find_by_id).with(12).and_return(lead)
      UserMailer.should_receive(:invite_lead).with(lead, mykey: :myvalue).and_return(double("email_lead_invite", deliver: true))

      SendEmail.do_perform('invite_lead', 'CB::Core::Lead', 12, mykey: :myvalue)
    end

    it 'tries 2 times to fetch the record if it fails, then raise error if it fails the 2nd time' do
      SendEmail.stub(:retry_interval).and_return(0.001)
      CB::Core::Lead.should_receive(:find_by_id).with(12).twice.and_return(nil)
      expect{SendEmail.do_perform('invite_lead', 'CB::Core::Lead', 12)}.to raise_error('Can not find CB::Core::Lead with id 12')
    end
  end
end