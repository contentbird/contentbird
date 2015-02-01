require 'spec_helper'

describe API::V1::APIController do

  controller(API::V1::APIController) do
    def index
      @channel = 'my channel'
      content = 'my content'
      api_response [true, content]
    end
  end

  before do
    request.accept = "application/json"
  end

  context 'and result is NOT paginatable' do
    it 'creates a simple_response object with the request context and result, then uses its methods to format a proper json response and headers' do
      expected_response = { result: DummyContent.new(id: 12, title: 'my title', body: 'my body'),
                            sections: DummySection.new(id: 37, name: 'my news'),
                            tags: DummyTag.new(id: 42, label: 'music', score: 100) }

      CB::Api::SimpleResponse.stub(:new).with('my channel', 'my content', {context: ['sections', 'tags'], page: 2}).and_return(response_double=double('response double'))
      response_double.stub(:response_headers).and_return({})
      response_double.stub(:response_body).and_return(expected_response)

      get :index, context: ['sections', 'tags'], page: '2'

      response.body.should eq({ result: {id: 12, title: 'my title'},
                                sections: {name: 'my news'},
                                tags: {id: 42, label: 'music', score: 100} }.to_json)
    end
  end

  context 'and result is paginatable' do
    before do
      controller.stub(:supports_pagination?).with('my content').and_return(true)
    end

    it 'creates a simple_response object with the request context and result, then uses its methods to format a proper json response and headers' do

      expected_response = { meta:     {current_page: 2, total_pages: 4},
                            result:   DummyContent.new(id: 12, title: 'my title', body: 'my body'),
                            sections: DummySection.new(id: 37, name: 'my news'),
                            tags:     DummyTag.new(id: 42, label: 'music', score: 100) }

      CB::Api::PaginatedResponse.stub(:new).with('my channel', 'my content', {context: ['sections', 'tags'], page: 2}).and_return(response_double=double('response double'))
      response_double.stub(:response_headers).and_return({'pagination-current' => 2, 'pagination-last' => 4})
      response_double.stub(:response_body).and_return(expected_response)

      get :index, context: ['sections', 'tags'], page: '2'

      response.headers['pagination-current'].should eq 2
      response.headers['pagination-last'].should  eq 4
      response.body.should eq({ meta:     {current_page: 2, total_pages: 4},
                                result:   {id: 12, title: 'my title'},
                                sections: {name: 'my news'},
                                tags:     {id: 42, label: 'music', score: 100} }.to_json)
    end
  end

  describe '#supports_pagination' do
    it 'returns true if given object responds to :page and false otherwise' do
      controller.send('supports_pagination?', OpenStruct.new).should be_false
      controller.send('supports_pagination?', OpenStruct.new(page: 'something')).should be_true
    end
  end

end

class DummyContent
  include ActiveModel::Model
  include ActiveModel::SerializerSupport
  attr_accessor :id, :title, :body
end

class DummySection
  include ActiveModel::Model
  include ActiveModel::SerializerSupport
  attr_accessor :id, :name
end

class DummyTag
  include ActiveModel::Model
  include ActiveModel::SerializerSupport
  attr_accessor :id, :label, :score
end

class DummyContentSerializer < ActiveModel::Serializer
  root false
  attributes :id, :title
end

class DummySectionSerializer < ActiveModel::Serializer
  root false
  attributes :name
end