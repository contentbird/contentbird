require 'spec_helper'

describe ChannelsController do

  let(:channel_params) do
    { 'name' => 'new name',
      'url_prefix' => 'pre',
      'css' => 'path/to/my/css',
      'baseline' => 'My baseline',
      'cover' => 'my-cover.jpg',
      'remove_css' => true,
      'sections_attributes' => [{'forewords' => "bla bla"},
                                {'position' => '2'}]
    }
  end

  let(:dummy_channel) {OpenStruct.new(id: 12, name: 'my site', url_prefix: 'prefix')}

  before do
    @current_user = stub_login
    CB::Manage::Channel.stub(:new).with(@current_user).and_return(@service = double('service'))
    CB::Manage::ContentType.stub(:new).with(@current_user).and_return(@type_service = double('type service'))
    CB::Manage::Publication.stub(:new).with(@current_user).and_return(@publication_service = double('publication service'))
    @type_service.stub(:user_types).and_return ['book', 'photo']
  end

  describe '#index' do
    it 'assigns current_users\'s channels to @channels and render index' do
      @service.stub(:list).and_return ['my', 'channels']

      get :index

      assigns(:channels).should eq ['my', 'channels']
      response.should render_template :index
    end
  end

  describe '#show' do
    it 'assigns @type to the type matching the given id, @publications to its latest publications (with paging) and renders show' do
      @service.stub(:find).with('37').and_return(channel = double('channel'))
      @publication_service.stub(:list_for_channel).with(channel).and_return(double('publications', page: ['some', 'publications']))
      channel.stub(:last_publication_at).and_return '3.hours.ago'

      get :show, id: '37'

      assigns(:channel).should eq channel
      assigns(:publications).should eq ['some', 'publications']
      assigns(:last_publication_at).should eq '3.hours.ago'
      response.should render_template :show
    end
  end

  describe "#new" do
    it 'assigns @channel, @user_types and render new' do
      @service.stub(:build_new).and_return 'my channel'

      get :new

      assigns(:channel).should    eq 'my channel'
      assigns(:user_types).should eq ['book', 'photo']
      response.should render_template :new
    end
  end

  describe '#create' do
    it 'asks the channel service to save the given channel and redirects to index' do
      @service.stub(:create).with(channel_params).and_return([true, 'created channel'])

      put :create, channel: channel_params

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end

    it 'assigns @channel, @user_types and renders new if channel creation failed' do
      @service.stub(:create).with(channel_params).and_return([false, 'not created channel'])

      put :create, channel: channel_params

      assigns(:channel).should             eq 'not created channel'
      assigns(:user_types).should eq ['book', 'photo']
      response.should render_template :new
    end
  end

  describe '#edit' do
    it 'assigns @channel to a newly created channel and render edit' do
      @service.stub(:find).with('37').and_return 'my channel'

      get :edit, id: '37'

      assigns(:channel).should  eq 'my channel'
      assigns(:user_types).should         eq ['book', 'photo']
      response.should render_template :edit
    end
  end

  describe '#update' do
    it 'asks the channel service to save the given channel' do
      @service.should_receive(:update).with('37', channel_params).and_return([true, dummy_channel])

      post :update, id: '37', channel: channel_params

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end

    it 'assigns @user_types, @channel and render edit when service update returns failure' do
      @service.should_receive(:update).with('37', channel_params).and_return([false, dummy_channel])

      post :update, id: '37', channel: channel_params

      assigns(:channel).should eq dummy_channel
      assigns(:user_types).should         eq ['book', 'photo']
      response.should render_template :edit
    end
  end

  describe '#reset_access_token' do
    before do
      request.env['HTTP_REFERER'] = 'previous page'
    end
    it 'asks the channel service to renew the access_token for the given channel, assigns @token, and redirect to previous page' do
      @service.should_receive(:reset_access_token).with('37').and_return([true, 'new_token'])

      get :reset_access_token, id: '37'

      assigns(:token).should eq 'new_token'
      flash[:notice].should_not be_empty
      response.should redirect_to 'previous page'
    end

    it 'displays a flash error if access_token renewal fails' do
      @service.should_receive(:reset_access_token).with('37').and_return([false, 'old_token'])

      get :reset_access_token, id: '37'

      assigns(:token).should eq 'old_token'
      flash[:alert].should_not be_empty
      response.should redirect_to 'previous page'
    end
  end

  describe '#destroy' do
    it 'asks the service to destroy channel matching the given channel_id and redirect_to index with a notice' do
      @service.should_receive(:destroy).with('37').and_return true

      get :destroy, id: '37'

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end

     it 'asks the service to destroy channel matching the given channel_id and redirect_to index with an alert if destruction failed' do
      @service.should_receive(:destroy).with('37').and_return false

      get :destroy, id: '37'

      flash[:alert].should_not be_empty
      response.should redirect_to channels_path
    end
  end

  describe '#open' do
    it 'asks the channel service to open the given channel and redirect to index' do
      @service.should_receive(:openit).with('37').and_return [true, 'my channel']

      get :open, id: '37'

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end
    it 'asks the channel service to open the given channel and redirect to index displaying an error if the opening process failed' do
      @service.should_receive(:openit).with('37').and_return [false, 'my channel']

      get :open, id: '37'

      flash[:alert].should_not be_empty
      response.should redirect_to channels_path
    end
  end

  describe '#close' do
    it 'asks the channel service to close the given channel and redirect to index' do
      @service.should_receive(:closeit).with('37').and_return [true, 'my channel']

      get :close, id: '37'

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end
    it 'asks the channel service to close the given channel and redirect to index displaying an error if the closing process failed' do
      @service.should_receive(:closeit).with('37').and_return [false, 'my channel']

      get :close, id: '37'

      flash[:alert].should_not be_empty
      response.should redirect_to channels_path
    end
  end

end