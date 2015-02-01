class API::V1::ContentsController < API::V1::ChannelSecuredController

  def index
    api_response rescuer(CB::Query::Publication.new(@channel)).list
  end

  def show
    api_response rescuer(CB::Query::Publication.new(@channel)).find_by_url_alias(params[:id])
  end
end