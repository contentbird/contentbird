require 'spec_helper'

describe InviteAllLeads do
  describe "do_perform" do
    it 'use lead subscribe service to send invitations' do
      CB::Subscribe::Lead.stub(:new).and_return lead_service = double('lead service')

      lead_service.should_receive(:invite_all)

      InviteAllLeads.do_perform
    end
  end
end