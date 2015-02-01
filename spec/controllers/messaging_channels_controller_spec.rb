require 'spec_helper'

describe MessagingChannelsController do

  let(:channel_params) do
    {
      'name'        => 'my_friends',
      'provider'    => 'email',
      'url_prefix'  => 'me'
    }
  end

  let(:dummy_channel) {OpenStruct.new(id: 12, name: 'my site', url_prefix: 'prefix')}

  before do
    @current_user = stub_login(OpenStruct.new(id: 3))
    CB::Manage::MessagingChannel.stub(:new).with(@current_user).and_return(@service = double('service'))
  end

  describe "#new" do
    it 'asks the channel service to build a new messaging_channel, sets it as @channel and renders new view' do
      @service.stub(:build_new).and_return 'new_channel'

      get :new

      assigns(:channel).should eq              'new_channel'
      response.should          render_template :new
    end
  end

  describe '#create' do
    it 'asks the channel service to save the given channel and redirects to index' do
      @service.stub(:create).with(channel_params).and_return([true, 'created channel'])

      put :create, channel: channel_params

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end

    it 'assigns @channels and renders new if channel creation failed' do
      @service.stub(:create).with(channel_params).and_return([false, 'not created channel'])

      put :create, channel: channel_params

      assigns(:channel).should             eq 'not created channel'
      response.should render_template :new
    end
  end

end