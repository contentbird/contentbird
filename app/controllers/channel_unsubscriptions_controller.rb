class ChannelUnsubscriptionsController < ApplicationController
  layout 'full_page'

  def new
    @channel = CB::Core::MessagingChannel.find(params[:channel_id])
  end

  def create
    @channel = CB::Core::MessagingChannel.find(params[:channel_id])
    @subscription = CB::Core::ChannelSubscription.find_for_channel_and_email(@channel, params[:email])
    if @subscription.present?
      destroyed = @subscription.destroy
      return redirect_to new_channel_unsubscription_path(channel_id: @channel.id), alert: t('.error') unless destroyed
    else
      redirect_to new_channel_unsubscription_path(channel_id: @channel.id), alert: t('.wrong_email')
    end
  end
end