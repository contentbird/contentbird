require 'spec_helper'

describe APIChannelsController do

  let(:api_channel_params) do
    {
      'name'        => 'new name',
      'url_prefix'  => 'pre'
    }
  end

  let(:dummy_channel) {OpenStruct.new(id: 12, name: 'my site', url_prefix: 'prefix')}

  before do
    @current_user = stub_login(OpenStruct.new(id: 3))
    CB::Manage::APIChannel.stub(:new).with(@current_user).and_return(@service = double('service'))
    CB::Manage::ContentType.stub(:new).with(@current_user).and_return(@type_service = double('type service'))
    @type_service.stub(:user_types).and_return ['book', 'photo']
  end

  describe "#new" do
    it 'asks the channel service to build a new api channel and renders new' do
      @service.should_receive(:build_new).and_return 'my new api channel'

      get :new

      assigns(:channel).should  eq 'my new api channel'
      assigns(:user_types).should           eq ['book', 'photo']
      response.should           render_template :new
    end

  end

  describe '#create' do
    it 'asks the channel service to save the given channel and redirects to index' do
      @service.stub(:create).with(api_channel_params).and_return([true, 'created channel'])

      put :create, channel: api_channel_params

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end

    it 'assigns @channel, @user_types and renders new if channel creation failed' do
      @service.stub(:create).with(api_channel_params).and_return([false, 'not created channel'])

      put :create, channel: api_channel_params

      assigns(:channel).should    eq 'not created channel'
      assigns(:user_types).should eq ['book', 'photo']
      response.should             render_template :new
    end
  end

end