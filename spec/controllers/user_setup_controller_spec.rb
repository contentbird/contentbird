require 'spec_helper'

describe UserSetupController do
  
  before do
    @current_user = stub_login
  end

  describe '#new' do
    it 'assigns @website_channel and @social_channels_summary and render the new view' do
      @current_user.stub(:first_website_channel).and_return 'my webite channel'
      @current_user.stub(:number_of_channels_by_provider).and_return({'twitter' => 1, 'linkedin' => 2})

      get :new
      
      assigns(:website_channel).should         eq 'my webite channel'
      assigns(:social_channels_summary).should eq({'twitter' => 1, 'linkedin' => 2})
    end
  end
end
