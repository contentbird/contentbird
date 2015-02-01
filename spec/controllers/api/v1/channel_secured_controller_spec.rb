require 'spec_helper'

describe API::V1::ChannelSecuredController do
  controller(API::V1::ChannelSecuredController) do
    def index
      render text: 'authenticated'
    end
  end

  before do
    CB::Access::Channel.stub(:new).and_return(cred_double = double)
    CB::Util::ServiceRescuer.stub(:new).with(cred_double).and_return(@cred_service = double('cred_service'))
    request.accept = "application/json"
  end

  context 'with valid channel credentials passed in header' do
    before do
      request.headers['CB-KEY']    = 'mykey'
      request.headers['CB-SECRET'] = 'mysecret'
      @cred_service.stub(:channel_for_credentials).with('mykey', 'mysecret').and_return([true, @channel = double('channel')])
    end

    it 'assigns @channel and proceed with requested action' do
      get :index
      assigns(:channel).should eq @channel
      response.body.should eq 'authenticated'
    end
  end
  context 'without valid channel credentials passed in header' do
    before do
      request.headers['CB-KEY']    = 'wrongkey'
      request.headers['CB-SECRET'] = 'wrongsecret'
      @cred_service.stub(:channel_for_credentials).with('wrongkey', 'wrongsecret').and_return([false, {error: :not_authorized, message: 'wrong channel credentials'}])
    end
    it 'returns a 403 with the error message in json format' do
      get :index

      response.status.should eq 403
      response.body.should eq({message: 'wrong channel credentials'}.to_json)
    end
  end
end