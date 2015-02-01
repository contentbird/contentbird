require 'spec_helper'

describe API::V1::HomeContentsController do

  before do
    request.accept = "application/json"
    send_channel_creds_for(double('channel'))
    controller.stub(:render)
  end

  describe '#index' do
    before do
      CB::Query::Publication.stub(:new).with(@channel).and_return(pub_double = double)
      CB::Util::ServiceRescuer.stub(:new).with(pub_double).and_return(@publication_service = double('publication_service'))
      @publication_service.stub(:list_for_home).and_return([true, {some: 'content'}])
    end

    it 'retrieves the channel matching the credentials, and returns its home contents as json' do
      api_data_should_be([true, {some: 'content'}]) do
        get :index
      end
    end

  end
end