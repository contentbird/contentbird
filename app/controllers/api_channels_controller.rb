class APIChannelsController < ChannelsController

  private

  def load_service
    @channel_service      = CB::Manage::APIChannel.new(current_user)
    @content_type_service = CB::Manage::ContentType.new(current_user)
  end

  def channel_params
    params.require(:channel).permit(:name, :url_prefix, sections_attributes: [:id, :label, :title, :position, :forewords, :content_type_id, :channel_id, :mode, :_destroy])
  end

end