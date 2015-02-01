def channel_creds_http_login
  login = CHANNEL_CREDS_LOGIN
  password = CHANNEL_CREDS_PASSWORD
  request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(login,password)
end

def send_channel_creds_for channel
  CB::Access::Channel.stub(:new).and_return(cred_double = double)
  CB::Util::ServiceRescuer.stub(:new).with(cred_double).and_return(cred_service = double('cred_service'))
  cred_service.stub(:channel_for_credentials).and_return [true, @channel=channel]
end