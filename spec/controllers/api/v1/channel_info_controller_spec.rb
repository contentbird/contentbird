require 'spec_helper'

describe API::V1::ChannelInfoController do

  describe '#show' do

    before do
      request.accept = "application/json"
      CB::Access::Channel.stub(:new).and_return(cred_double = double)
      CB::Util::ServiceRescuer.stub(:new).with(cred_double).and_return(@cred_service = double('cred_service'))
    end

    context 'given request is authenticated with http basic' do

      before do
        channel_creds_http_login
      end

      it 'finds the channel matching the given prefix_id and return its info in JSON format' do
        @cred_service.stub(:info_for_prefix).with('my-prefix').and_return([true, {key: 'chan-key', secret_key: 'chan-token', type: 'website'}])

        get :show, id: 'my-prefix'

        response.status.should eq 200
        response.body.should eq({result: {key: 'chan-key', secret_key: 'chan-token', type: 'website'}}.to_json)
      end

      it 'returns a 404 with a message in JSON format if the channel can not be found' do
        @cred_service.stub(:info_for_prefix).with('my-prefix').and_return([false, {error: :not_found, message: 'I cannot find it'}])

        get :show, id: 'my-prefix'

        response.status.should eq 404
        response.body.should eq({message: 'I cannot find it'}.to_json)
      end

      it 'returns a 500 with a message in JSON format if the credential retrieval failed' do
        @cred_service.stub(:info_for_prefix).with('my-prefix').and_return([false, {error: :exception, message: 'ooops I crash'}])

        get :show, id: 'my-prefix'

        response.status.should eq 500
        response.body.should eq({message: 'ooops I crash'}.to_json)
      end
    end

    it 'returns an http basic authentication request' do
      get :show, id: 'my-prefix'
      response.status.should eq 401
    end
  end
end