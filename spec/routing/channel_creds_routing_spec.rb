require 'spec_helper'

describe 'channel_info routing' do

  context 'with api. subdomain and https protocol' do
    # before do
    #   set_subdomain_and_https('api')
    # end

    context 'with no version in header' do
      it 'routes to v1' do
        get('https://test.host/api/channel_info/myprefix').should route_to(controller: 'api/v1/channel_info', action: 'show', id: 'myprefix')
      end
    end

    context 'with v1 in header' do
      before do
        set_accept_header_to "application/vnd.contentbirdme.v1"
      end
      it 'routes to v1' do
        get('https://test.host/api/channel_info/myprefix').should route_to(controller: 'api/v1/channel_info', action: 'show', id: 'myprefix')
      end
    end

    context 'with v2 in header' do
      before do
      set_accept_header_to "application/vnd.contentbird.v2"
      end
      it 'routes to v2' do
        get('https://test.host/api/channel_info/api/myprefix').should route_to(controller: 'api/v2/channel_info', action: 'show', id: 'myprefix')
      end
    end

  end

  context 'without https' do
    context 'with no version in header' do
      it 'an API request does not route' do
        get('http://test.host/app/api/channel_info/myprefix').should_not be_routable
      end
    end
  end

private
  def set_accept_header_to accept_header_text=''
    existing_hash = Rack::MockRequest.env_for('https://test.host/api/channel_info/myprefix', {method: :get})
    Rack::MockRequest.stub(:env_for).and_return(existing_hash.merge('HTTP_ACCEPT' => accept_header_text))
  end

  # def set_subdomain_and_https subdomain='sub'
  #   existing_hash = Rack::MockRequest.env_for('https://test.host/channel_info/myprefix', {method: :get})
  #   Rack::MockRequest.stub!(:env_for).and_return(existing_hash.merge!('HTTP_HOST' => "#{subdomain}.local.me"))
  # end

  # def set_subdomain_without_https subdomain='sub'
  #   existing_hash = Rack::MockRequest.env_for('http://test.host/channel_info/myprefix', {method: :get})
  #   Rack::MockRequest.stub!(:env_for).and_return(existing_hash.merge!('HTTP_HOST' => "#{subdomain}.local.me"))
  # end

end