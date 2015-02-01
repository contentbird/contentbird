class MessagingChannelsController < ChannelsController

  def new
    @channel = @channel_service.build_new new_channel_params
  end

  def edit
    @channel   = @channel_service.find(params[:id])
  end

private

  def load_service
    @channel_service = CB::Manage::MessagingChannel.new(current_user)
  end

  def channel_params
    params.require(:channel).permit(:name, :url_prefix, :baseline, :cover, :css, :allow_social_feed, :provider, subscriptions_attributes: [:id, :contact_id, :channel_id, :_destroy])
  end

  def load_user_content_types
  end

  def new_channel_params
    params.permit(:provider)
  end
end