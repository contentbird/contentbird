require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render nothing: true
    end
  end

  describe "#restrict_access" do
    it 'does not autorize non whitelisted IP for front' do
      with_constants  :IP_WHITELIST => {'9.9.9.9' => 'authorized IP'},
                      :IP_FILTERING => true do
        get :index
        response.body.should eq "IP 0.0.0.0 Not authorized"
      end
    end
  end

  describe "#reject_old_browsers" do
    it 'renders a bounce page for IE less than 10 browers' do
      request.env["HTTP_USER_AGENT"] = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"
      get :index
      response.should render_template :old_browser
    end
  end

  describe "#set_locale" do
    before do
      @current_user = stub_login(OpenStruct.new(id: 3))
      Rails.stub(:env).and_return OpenStruct.new(test?: false) # remove test locale behavior for this test only
    end

    it 'should return default locale' do
      get :index

      I18n.locale.should eq :test
    end

    context 'given EN locale is set in HTTP_ACCEPT_LANGUAGE' do
      before do
        request.env["HTTP_ACCEPT_LANGUAGE"] = 'en-gb'
      end
      it 'should set locale to given locale' do
        get :index

        I18n.locale.should eq :en
      end
    end

    context 'given an unsupported locale is set in HTTP_ACCEPT_LANGUAGE' do
      before do
        request.env["HTTP_ACCEPT_LANGUAGE"] = 'da'
      end
      it 'should set locale to default' do
        get :index

        I18n.locale.should eq :test
      end
    end

    context 'given the logged in user has a prefered locale' do
      before do
        @current_user = stub_login(OpenStruct.new(id: 3, locale: 'es'))
      end
      it 'should set locale to users preference' do
        get :index

        I18n.locale.should eq :es
      end

      it 'should step over supported locale provided by HTTP_ACCEPT_LANGUAGE' do
        request.env["HTTP_ACCEPT_LANGUAGE"] = 'pt'
        get :index

        I18n.locale.should eq :es
      end
    end
  end
end