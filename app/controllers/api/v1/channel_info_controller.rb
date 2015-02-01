class API::V1::ChannelInfoController < API::V1::APIController

  http_basic_authenticate_with name: CHANNEL_CREDS_LOGIN, password: CHANNEL_CREDS_PASSWORD

  def show
    api_response rescuer(CB::Access::Channel.new).info_for_prefix(params[:id])
  end

private

  def serialize_response response, context_data={}
    response.to_json
  end

end