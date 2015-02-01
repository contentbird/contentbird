require 'spec_helper'

describe ContactsController do

  before do
    @current_user = stub_login OpenStruct.new(email: 'owner@email.com')
    CB::Manage::Contact.stub(:new).with(@current_user).and_return(@service = double('contact service'))
  end

  describe '#create' do
    it 'finds or creates a for this owner and the given email (downcased), and returns a json formatted contact' do
      @service.stub(:find_or_create_by_email)
              .with('my@email.com')
              .and_return [true, OpenStruct.new(owner_id: 3, email: 'my@email.com', id: 42)]

      post :create, email: 'my@EmAil.com'

      response.body.should eq({id: 42, email: 'my@email.com'}.to_json)
    end

    it 'returns a json with info if given email is current_user\'s email' do

      post :create, email: @current_user.email

      response.body.should   eq({ your_own_email: { msg: 'No need to add yourself to the list : You will receive a copy of every email' } }.to_json)
      response.status.should eq 200
    end

    it 'returns a json with an error and a 500 status if create or find was a failure' do
      @service.stub(:find_or_create_by_email)
              .with('my@email.com')
              .and_return [false, OpenStruct.new(owner_id: nil, email: 'my@email.com', id: nil)]

      post :create, email: 'my@email.com'

      response.body.should   eq({ error: { msg: 'Error while creating your contact' } }.to_json)
      response.status.should eq 500
    end
  end

end