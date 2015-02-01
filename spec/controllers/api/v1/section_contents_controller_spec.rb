require 'spec_helper'

describe API::V1::SectionContentsController do

  before do
    request.accept = "application/json"
    send_channel_creds_for double('channel')
    CB::Query::Publication.stub(:new).with(@channel).and_return(pub_double = double)
    CB::Util::ServiceRescuer.stub(:new).with(pub_double).and_return(@publication_service = double('publication service'))
    CB::Query::Content.stub(:new).with(@channel).and_return(content_double = double)
    CB::Util::ServiceRescuer.stub(:new).with(content_double).and_return(@content_service = double('content service'))
    controller.stub(:render)
  end

  describe '#index' do
    it 'queries the content service for contents in the given section slug and returns the result as an API response' do
      @publication_service.stub(:list_for_section_slug).with('my-section-slug').and_return([true, {some: 'content'}])

      api_data_should_be([true, {some: 'content'}]) do
        get :index, section_slug: 'my-section-slug'
      end
    end
  end

  describe '#show' do
    it 'uses the content service to find the content matching the given content and section slugs and returns the result as an API response' do
      @publication_service.stub(:find_by_slug_and_section_slug).with('my-content-slug', 'my-section-slug').and_return([true, {some: 'content'}])
      api_data_should_be([true, {some: 'content'}]) do
        get :show, id: 'my-content-slug', section_slug: 'my-section-slug'
      end
    end
  end

  describe '#new' do
    it 'uses the content service to populate a new the content in the given section and returns the result as an API response' do
      @content_service.stub(:new_for_section_slug).with('my-section-slug').and_return([true, {thenew: 'content'}])
      api_data_should_be([true, {thenew: 'content'}]) do
        get :new, section_slug: 'my-section-slug'
      end
    end
  end

  describe '#create' do
    it 'uses the content service to create a new content with given params and returns it as API response' do
      content_hash = {'title' => 'my_title', 'properties' => {'author' => 'the_author', 'cover'=> 'path/to/cover.jpg'}}
      @content_service.should_receive(:create_for_section_slug).with('my-section-slug', content_hash).and_return([true, 'created content' ])
      api_data_should_be([true, 'created content']) do
        post :create, section_slug: 'my-section-slug', content: content_hash
      end
    end
  end

end