require 'spec_helper'

describe InvitationsController do

  describe '#create' do
    before do
      @current_user = stub_login
      request.env["HTTP_REFERER"] = '/previous/page'
    end
    it 'enqueues a SendEmail job passing the given email and display an information notice' do
      JobRunner.should_receive(:run).with(SendEmail, 'invitation', 'CB::Core::User', @current_user.id, 'email' => 'toto@toto.com')

      post :create, email: 'toto@toto.com'

      flash[:notice].should_not be_nil
      response.should redirect_to '/previous/page'
    end
  end

end