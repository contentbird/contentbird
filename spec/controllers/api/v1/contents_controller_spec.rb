require 'spec_helper'

describe API::V1::ContentsController do

  before do
    request.accept = "application/json"
    send_channel_creds_for double('channel')
    CB::Query::Publication.stub(:new).with(@channel).and_return(pub_double = double)
    CB::Util::ServiceRescuer.stub(:new).with(pub_double).and_return(@publication_service = double('content service'))
    controller.stub(:render)
  end

  describe '#index' do
    it 'queries the content service for contents in the given section slug and returns the result as an API response' do
      @publication_service.stub(:list).and_return([true, {some: 'content'}])

      api_data_should_be([true, {some: 'content'}]) do
        get :index
      end
    end
  end

  describe '#show' do
    it 'uses the content service to find the content matching the given publication url_alias and returns the result as an API response' do
      @publication_service.stub(:find_by_url_alias).with('my-url-alias').and_return([true, {some: 'content'}])
      api_data_should_be([true, {some: 'content'}]) do
        get :show, id: 'my-url-alias'
      end
    end
  end

end