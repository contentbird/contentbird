require 'spec_helper'

describe ContentTypesController do

  let(:type_params) do
    { 'title'                 => 'new title',
      'title_label'           => 'new title label',
      'properties_attributes' => [
                                  {'id' => '13', 'title' => 'title', 'position' => '0', 'content_type_id' => '36'},
                                  {'id' => '14', 'title' => 'summary', 'position' => '1', 'content_type_id' => '38'}
                                  ]}
  end

  before do
    @current_user = stub_login
    CB::Manage::ContentType.stub(:new).with(@current_user).and_return(@service = double('service'))
    @service.stub(:selectable_types).and_return ['text', 'memo']
  end

  describe "#index" do
    it 'assigns current_user\'s content types to @types and render index view' do
      @service.stub(:user_types).and_return(double('user types', with_owner: ['my', 'types']))

      get :index

      assigns(:types).should eq ['my', 'types']
      response.should render_template :index
    end
  end

  describe "#new" do
    it 'assigns @type, @selectable_types and render new' do
      @service.stub(:build_new).and_return  'my type'

      get :new

      assigns(:type).should             eq 'my type'
      assigns(:selectable_types).should eq ['text', 'memo']
      response.should render_template :new
    end
  end

  describe '#create' do
    it 'asks the content type service to save the given type' do
      @service.stub(:create).with(type_params).and_return([true, 'created type'])

      put :create, content_type: type_params

      flash[:notice].should_not be_empty
      response.should redirect_to content_types_path
    end

    it 'asks the content type service to save the given type' do
      @service.stub(:create).with(type_params).and_return([false, 'not created type'])

      put :create, content_type: type_params

      assigns(:type).should             eq 'not created type'
      assigns(:selectable_types).should eq ['text', 'memo']
      response.should render_template :new
    end
  end

  describe '#edit' do

    it 'assigns @type, @selectable_types and render edit' do
      @service.stub(:find).with('37').and_return(my_type = double('type', owned_by?: true))

      get :edit, id: '37'

      assigns(:type).should             eq my_type
      assigns(:selectable_types).should eq ['text', 'memo']
      response.should render_template :edit
    end

    context 'given the content_type is not owned by the current_user' do
      before do
        @service.stub(:find).with('37').and_return(@shared_type = double('shared type', owned_by?: false))
      end
      it 'forks the content_type, assigns it to @type, assigns @forked_type and @selectable_types and render edit' do
        @service.should_receive(:build_forked_type).with(@shared_type).and_return(new_type = double('owned type', owned_by?: true))

        get :edit, id: '37'

        assigns(:type).should             eq new_type
        assigns(:forked_type).should      eq @shared_type
        assigns(:selectable_types).should eq ['text', 'memo']
        response.should render_template :new
      end
    end
  end

  describe '#update' do
    it 'asks the content type service to save the given type' do
      @service.should_receive(:update).with('37', type_params).and_return([true, 'updated type'])

      post :update, id: '37', content_type: type_params

      flash[:notice].should_not be_empty
      response.should redirect_to content_types_path
    end

    it 'assigns @selectable_types, @type and render edit when service update returns failure' do
      @service.stub(:update).with('37', type_params).and_return([false, 'not updated type'])

      post :update, id: '37', content_type: type_params

      assigns(:type).should             eq 'not updated type'
      assigns(:selectable_types).should eq ['text', 'memo']
      response.should render_template :edit
    end
  end

  describe '#destroy' do
    it 'asks the service to destroy type matching the given type_id and redirect_to index with a notice' do
      @service.should_receive(:destroy).with('37').and_return true

      get :destroy, id: '37'

      flash[:notice].should_not be_empty
      response.should redirect_to content_types_path
    end

     it 'asks the service to destroy type matching the given type_id and redirect_to index with an alert if destruction failed' do
      @service.should_receive(:destroy).with('37').and_return false

      get :destroy, id: '37'

      flash[:alert].should_not be_empty
      response.should redirect_to content_types_path
    end
  end
end