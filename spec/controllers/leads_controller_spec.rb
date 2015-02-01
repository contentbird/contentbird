require 'spec_helper'

describe LeadsController do

  describe '#new' do
    it 'assigns a new lead and renders the :new view' do
      CB::Core::Lead.stub(:new).and_return 'the lead'
      get :new
      assigns(:lead).should eq 'the lead'
      response.should render_template :new
    end
  end

  describe '#create' do
    it 'asks the lead subscribe service to create a lead with given email and redirect to home with notice' do
      CB::Subscribe::Lead.stub(:new).and_return(subscribe_service = double('subscribe service'))
      subscribe_service.should_receive(:create).with('toto@toto.com').and_return [true, 'my lead']

      post :create, lead: {email: 'toto@toto.com'}

      flash[:notice].should_not be_nil
      response.should redirect_to root_path
    end

    it 'asks the lead subscribe service to create a lead with given email and assigns @lead and render home beta it creation failed' do
      CB::Subscribe::Lead.stub(:new).and_return(subscribe_service = double('subscribe service'))
      subscribe_service.should_receive(:create).with('toto@toto.com').and_return [false, 'my lead']

      post :create, lead: {email: 'toto@toto.com'}

      assigns(:lead).should eq 'my lead'
      flash[:alert].should_not be_nil
      response.should redirect_to new_lead_path
    end
  end

end