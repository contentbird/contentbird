class API::V1::ChannelSecuredController < API::V1::APIController
  before_action :retrieve_channel_matching_credentials
private
  def retrieve_channel_matching_credentials
    success, result = rescuer(CB::Access::Channel.new).channel_for_credentials(request.headers['CB-KEY'], request.headers['CB-SECRET'])
    if success
      @channel = result
    else
      api_response [false, result]
    end
  end
end