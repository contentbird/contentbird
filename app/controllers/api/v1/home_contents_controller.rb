class API::V1::HomeContentsController < API::V1::ChannelSecuredController
  def index
    api_response rescuer(CB::Query::Publication.new(@channel)).list_for_home
  end
end