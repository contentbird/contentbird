require 'spec_helper'

describe RegistrationsController do
  include Devise::TestHelpers
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    context 'given registrations are opened' do
      context 'with no token as parameter' do
        it 'displays the signup form' do
          get :new
          display_signup_form_with_token_and_email
        end
      end
      context 'with a valid token as parameter' do
        it 'assigns the token and the lead email to the user' do
          CB::Core::Lead.create token: 'valid_token', email: 'mysuper@email.io'
          get :new, token: 'valid_token'
          display_signup_form_with_token_and_email 'valid_token', 'mysuper@email.io'
        end
      end
      context 'with an invalid token as parameter' do
        it 'does not assign the token to the user but displays the signup form as usual' do
          get :new, token: 'invalid_token'
          display_signup_form_with_token_and_email
        end
      end
    end

    context 'given registrations are closed' do
      around(:each) do |example|
        with_constants :REGISTRATION_ACTIVE => false do example.run end
      end

      context 'with no token parameter' do
        it 'displays the lead form' do
          get :new

          response.should redirect_to new_lead_path
        end
      end

      context 'with a valid token as parameter' do
        it 'assigns the token and the lead email to the user' do
          CB::Core::Lead.create token: 'valid_token', email: 'mysuper@email.io'
          get :new, token: 'valid_token'
          display_signup_form_with_token_and_email 'valid_token', 'mysuper@email.io'
        end
      end

      context 'with an invalid token as parameter' do
        it 'redirects to new lead path' do
          get :new, token: 'invalid_token'

          response.should redirect_to new_lead_path
        end
      end
    end
  end

  describe '#create' do
    before do
      @signup_params = {nest_name: 'test', email: 'test@test.com', password: 'testtest', password_confirmation: 'testtest'}
    end

    it 'instanciates a CB::Build::Account service and asks it to give the user the default content_type usages' do
      controller.stub(:resource).and_return(@resource=CB::Core::User.new(@signup_params))
      @resource.stub(:persisted?).and_return(true)

      CB::Build::Account.stub(:new).with(@resource).and_return(@service_mock=double('build service'))

      @service_mock.should_receive(:set_default_content_types_usages)
      @service_mock.should_receive(:create_default_website).never

      post :create, user: @signup_params
    end

    it 'asks the CB::Build::Account service to create a default website for the user if he is advanced' do
      controller.stub(:resource).and_return(@resource=CB::Core::User.new(@signup_params))
      @resource.stub(:persisted?).and_return(true)
      @resource.stub(:advanced?).and_return(true)

      CB::Build::Account.stub(:new).with(@resource).and_return(@service_mock=double('build service'))

      @service_mock.should_receive(:set_default_content_types_usages)
      @service_mock.should_receive(:create_default_website)

      post :create, user: @signup_params
    end

    it 'burns the lead matching the user beta token if passed' do
      CB::Core::Lead.create!(token: 'my_token', email: 'test@test.com')
      CB::Subscribe::Lead.stub(:new).and_return(lead_service = double('lead_service'))

      lead_service.should_receive(:burn).with('my_token')

      post :create, user: @signup_params.merge(token: 'my_token')

      CB::Core::User.last.email.should eq 'test@test.com'
    end

    it 'redirects to tunnel after sign_up' do
      post :create, user: @signup_params

      response.should redirect_to(new_user_setup_path)
    end
  end

  describe '#destroy' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it 'enqueues a DeleteUser job, signs out the user and redirect to home' do
      JobRunner.should_receive(:run).with(DeleteUser, @user.id)

      delete :destroy, user: @user

      controller.current_user.should  be_nil
      response.should                 redirect_to root_path
    end
  end
end

def display_signup_form_with_token_and_email token=nil, email=''
  controller.resource.token.should eq token
  controller.resource.email.should eq email
  response.should be_success
  response.should render_template :new
end