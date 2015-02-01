require 'spec_helper'
require 'cb/core/channel'

describe ChannelUnsubscriptionsController do

  describe '#new' do
    it 'finds the channel matching the given channel_id and renders new' do
      CB::Core::MessagingChannel.stub(:find).with('37').and_return 'my_channel'

      get :new, channel_id: '37'

      assigns(:channel).should eq 'my_channel'
      response.should render_template(:new)
    end
  end

  describe '#create' do
    before do
      CB::Core::MessagingChannel.stub(:find).with('37').and_return(@channel = double('channel', id: 37))
    end
    context 'given email matches subscriptions contact email' do
      before do
        CB::Core::ChannelSubscription.stub(:find_for_channel_and_email)
                                     .with(@channel, 'matching@email.com')
                                     .and_return(@subscription = double('subscription'))
      end
      it 'checks email, destroys the subscription and renders create view' do
        @subscription.should_receive(:destroy).and_return true

        post :create, channel_id: '37', email: "matching@email.com"

        response.should render_template :create
      end
      it 'redirects to new with an error if destruction failed' do
        @subscription.should_receive(:destroy).and_return false

        post :create, channel_id: '37', email: "matching@email.com"

        response.should redirect_to new_channel_unsubscription_path(channel_id: 37)
        flash[:alert].should_not be_nil
      end
    end
    context 'given another email' do
      before do
        CB::Core::ChannelSubscription.stub(:find_for_channel_and_email)
                                     .with(@channel, 'wildguess@email.com')
                                     .and_return(nil)
      end
      it 'checks email and redirects to new with error' do
        post :create, channel_id: '37', email: "wildguess@email.com"

        response.should redirect_to new_channel_unsubscription_path(channel_id: 37)
        flash[:alert].should_not be_nil
      end
    end
  end

end