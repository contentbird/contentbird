require 'spec_helper'

describe ContentsController do

  let(:form_params) do
    { 'title' => 'new title',
      'content_type_id' => '37',
      'properties' => {'12' => 'this is the story of Steve', '42' => {'author' => 'Bob Wilson', 'score' => '5'}} }
  end

  let(:content_params) do
    { 'title' => 'new title',
      'properties' => {'12' => 'this is the story of Steve', '42' => {'author' => 'Bob Wilson', 'score' => '5'}} }
  end

  before do
    @current_user = stub_login
    CB::Manage::ContentType.stub(:new).with(@current_user).and_return(@type_service = double('type service'))
    CB::Manage::Content.stub(:new).with(@current_user).and_return(@content_service = double('content service'))
    CB::Manage::Channel.stub(:new).with(@current_user).and_return(@channel_service = double('channel service'))
  end

  describe '#index' do
    before do
      @channel_service.stub(:list).and_return(['two','channels'])
      @type_service.stub(:user_types).and_return(['two', 'types'])
      @contents_mock = double(:contents, page: (paged_double = double(:contents, per: ['two','contents'])))
    end

    context 'given no content type id is passed' do
      it 'assigns @contents to recent contents of any type, @types to all user content_types, handles display mode and renders index' do
        @content_service.stub(:recent).and_return @contents_mock

        get :index

        assigns(:types).should eq ['two','types']
        assigns(:type).should be_nil
        assigns(:contents).should eq ['two','contents']
        session['content_layout'].should eq 'cards'
        response.should render_template :index

        get :index, display_mode: 'grid'
        session['content_layout'].should eq 'grid'

        get :index
        session['content_layout'].should eq 'grid'

        get :index, display_mode: 'cards'
        session['content_layout'].should eq 'cards'

        get :index
        session['content_layout'].should eq 'cards'
      end
    end

    context 'given content type id "all" is passed' do
      it 'assigns @contents to recent contents of any type, @types to all user content_types and renders index' do
        @content_service.stub(:recent).and_return @contents_mock

        get :index, content_type_id: 'all'

        assigns(:types).should      eq ['two','types']
        assigns(:type).should       be_nil
        assigns(:contents).should   eq ['two','contents']
        response.should             render_template :index
      end
    end

    context 'given a real content type id is passed' do
      it 'assigns @type, @contents to recent contents in that type, @types to all user content_types and renders index' do
        @type_service.stub(:find).with('37').and_return(type_double = double('type'))
        @content_service.stub(:recent_for_type).with(type_double).and_return @contents_mock

        get :index, content_type_id: '37'

        assigns(:types).should      eq ['two','types']
        assigns(:type).should       eq type_double
        assigns(:contents).should   eq ['two','contents']
        response.should             render_template :index
      end
    end

    context 'given no content_type_id is passed but user typed a search string' do
      it 'assigns @type, @contents to recent contents matching the search string, @types to all user content_types and renders index' do
        @content_service.stub(:recent).and_return(recent_contents_double = double('contents'))
        recent_contents_double.stub(:search_on_title).with('my search').and_return @contents_mock

        get :index, search: 'my search'

        assigns(:types).should    eq ['two','types']
        assigns(:type).should     be_nil
        assigns(:contents).should eq ['two','contents']
        response.should           render_template :index
      end
    end

    context 'given a real content_type_id is passed and user also typed a search string' do
      it 'assigns @type, @contents to recent contents matching the type and the search string, @types to all user content_types and renders index' do
       @type_service.stub(:find).with('37').and_return(type_double = double('type'))
        @content_service.stub(:recent_for_type).with(type_double).and_return(recent_contents_double = double('contents'))
        recent_contents_double.stub(:search_on_title).with('my search').and_return @contents_mock

        get :index, content_type_id: '37', search: 'my search'

        assigns(:types).should    eq ['two','types']
        assigns(:type).should     eq type_double
        assigns(:contents).should eq ['two','contents']
        response.should           render_template :index
      end
    end
  end

  describe '#show' do
    it 'assigns @content and renders show' do
      @content_service.stub(:find).with('37').and_return(content = double('my showed content', content_type: 'my content type'))

      get :show, id: '37'

      assigns(:content).should  eq content
      assigns(:type).should     eq 'my content type'
      response.should           render_template :show
    end
  end

  describe '#new' do
    before do
      @type_service.stub(:find).with('37').and_return(@type_double = double('type', translated_title: 'Magic Type'))
    end

    it 'assigns @content to newly created content for the current user, the current content_type and with a temp title and renders new' do
      @content_service.stub(:create).with(@type_double, {title: 'New magic type'}).and_return [true, content = OpenStruct.new(title: 'this is a temp title')]

      get :new, content_type_id: '37'

      content.title.should be_nil
      assigns(:content).should  eq content
      response.should           render_template :new
    end
    it 'assigns @content to newly built content for the current user, @newly_created to false, the current content_type and renders new if content creation failed' do
      @content_service.stub(:create).with(@type_double, {title: 'New magic type'}).and_return [false, 'new falsy content']

      get :new, content_type_id: '37'

      assigns(:content).should        eq 'new falsy content'
      assigns(:newly_created).should  be_false

      flash[:alert].should_not  be_empty
      response.should           redirect_to contents_path
    end
  end

  describe '#create' do
    before do
      @type_service.stub(:find).with('37').and_return(@type_double = double('type', id: 37, to_param: '37', name: 'Book', translated_title: 'book'))
      @type_double.stub(:properties).and_return [OpenStruct.new(id: '12'), OpenStruct.new(id: '42')]
    end
    it 'asks the content service to save the given content' do
      @content_service.should_receive(:create).with(@type_double, content_params).and_return([true, OpenStruct.new(id: 42)])

      post :create, content_type_id: '37', content: form_params

      flash[:notice].should_not be_empty
      response.should redirect_to content_path(42)
    end

    it 'assigns @content, and renders new again if creation failed' do
      @content_service.should_receive(:create).with(@type_double, content_params).and_return([false, 'not created content'])

      post :create, content_type_id: '37', content: form_params

      assigns(:content).should  eq 'not created content'
      response.should           render_template :new
    end
  end

  describe '#edit' do
    it 'assigns @content and render edit' do
      @content_service.stub(:find).with('37').and_return(content_double = double('content', content_type: 'my type'))

      get :edit, id: '37'

      assigns(:content).should  eq content_double
      assigns(:type).should     eq 'my type'
      response.should           render_template :edit
    end
  end

  describe '#update' do
    before do
      @content_double = double('content', id: 42)
      @type_service.stub(:find).with('37').and_return(@type_double = double('type', to_param: '37', name: 'Book', translated_title: 'book'))
      @type_double.stub(:properties).and_return [OpenStruct.new(id: '12'), OpenStruct.new(id: '42')]
    end

    it 'asks the content service to save the given content' do
      @content_service.should_receive(:update).with('23', content_params).and_return([true, @content_double])

      put :update, id: '23', content: form_params

      flash[:notice].should_not be_empty
      response.should redirect_to content_path(42)
    end

    it 'assigns @content, @type and render edit when service update returns failure' do
      @content_service.should_receive(:update).with('23', content_params).and_return([false, @content_double])

      put :update, id: '23', content: form_params

      assigns(:content).should eq @content_double
      assigns(:type).should    eq @type_double
      response.should render_template :edit
    end
  end

  describe '#destroy' do
    before do
      @type_double = double 'type', id: '23', translated_title: 'Book'
      @content = double 'content', content_type: @type_double, title: 'Ishmael'
    end
    it 'asks the service to destroy content matching the given id and redirect_to index with a notice' do
      @content_service.should_receive(:destroy).with('37').and_return [true, @content]

      get :destroy, id: '37'

      flash[:notice].should_not be_empty
      response.should redirect_to contents_path
    end

     it 'asks the service to destroy content matching the given id and redirect_to index with an alert if destruction failed' do
      @content_service.should_receive(:destroy).with('37').and_return [false, @content]

      get :destroy, id: '37'

      flash[:alert].should_not be_empty
      response.should redirect_to contents_path
    end
  end

  describe '#markdown_preview' do
    it 'calls markdown helper method to translate text to markdown html and assigns @preview' do
      controller.stub(:markdown).with("text to translate").and_return("translated text")

      post :markdown_preview, id: '37', text: "text to translate", format: 'js'

      response.body.should eq "translated text"
    end
  end

end