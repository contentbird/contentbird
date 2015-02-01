require 'spec_helper'

describe SocialChannelsController do

  let(:social_channel_params) do
    {
      'name'        => 'new name',
      'provider'    => 'twitter',
      'url_prefix'  => 'pre'
    }
  end

  let(:dummy_channel) {OpenStruct.new(id: 12, name: 'my site', url_prefix: 'prefix')}

  before do
    @current_user = stub_login(OpenStruct.new(id: 3))
    CB::Manage::SocialChannel.stub(:new).with(@current_user).and_return(@service = double('service'))
    CB::Manage::ContentType.stub(:new).with(@current_user).and_return(@type_service = double('type service'))
    @type_service.stub(:user_types).and_return ['book', 'photo']
  end

  describe "#new" do
    context 'without any omniauth info' do
      it 'renders new without building channel' do
        @service.should_receive(:build_new).never

        get :new

        assigns(:channel).should  be_nil
        response.should           render_template :choose
      end
    end

    context 'given an omniauth info' do
      before do
        request.env['omniauth.auth'] = {oauth: 'hash'}
        @service.stub(:build_new).with(oauth: request.env['omniauth.auth']).and_return(@channel_double = double('social channel', url_prefix: 'my-social-chan'))
      end

      it 'assigns @provider_token, @provider_secret from oauth, @channel and @user_types and render new' do
        get :new

        assigns(:channel).should    eq @channel_double
        assigns(:user_types).should eq ['book', 'photo']
        response.should render_template :new
      end

      context 'and user comes from registration tunnel' do
        before do
          request.env['omniauth.origin'] = new_user_setup_url
        end
        it 'set the channel owner to current user, saves the channel and redirects back to registration tunnel' do
          @channel_double.should_receive(:owner_id=).with(@current_user.id).and_return true
          @channel_double.should_receive(:save_with_new_url_prefix)
          get :new
          response.should redirect_to new_user_setup_path
        end
      end
      context 'and user comes from one of his channels' do
        before do
          request.env['omniauth.origin'] = social_channel_path(dummy_channel.id)
        end
        it 'call channel service to update the channel\'s credentials and redirects back to his channels page' do
          @service.should_receive(:update_credentials).with(dummy_channel.id.to_s, {oauth: 'hash'})

          get :new

          response.should redirect_to social_channel_path(dummy_channel.id)
        end
      end
    end

  end

  describe '#create' do
    it 'asks the channel service to save the given channel and redirects to index' do
      @service.stub(:create).with(social_channel_params).and_return([true, 'created channel'])

      put :create, channel: social_channel_params

      flash[:notice].should_not be_empty
      response.should redirect_to channels_path
    end

    it 'assigns @channel, @user_types and renders new if channel creation failed' do
      @service.stub(:create).with(social_channel_params).and_return([false, 'not created channel'])

      put :create, channel: social_channel_params

      assigns(:channel).should              eq 'not created channel'
      assigns(:user_types).should           eq ['book', 'photo']
      response.should render_template :new
    end
  end

  describe '#check_credentials' do
    it 'asks the channel service to check credentials for the given channel' do
      @service.stub(:check_credentials).with('37').and_return([true, credentials: {id: 12345, user_name: 'nna_test'}])

      get :check_credentials, id: '37', format: :js

      assigns(:credentials_ok).should be_true
      assigns(:credentials).should    eq({id: 12345, user_name: 'nna_test'})
    end
    it 'asks the channel service to check credentials and assigns @credentials_ok to false and @error_message with error message' do
      @service.stub(:check_credentials).with('37').and_return([false, {provider: 'twitter', message: 'Invalid or expired token', exception: 'some exception'}])

      get :check_credentials, id: '37', format: :js

      assigns(:credentials_ok).should be_false
      assigns(:error_message).should  eq 'Invalid or expired token'
      assigns(:provider).should       eq 'twitter'
    end
  end

end