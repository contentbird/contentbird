require 'spec_helper'

describe HomeController do

  describe '#index' do

    context 'given an anonymous user' do
      before do
        controller.stub(:current_user).and_return(nil)
      end
      it 'renders :index view' do
        get :index
        response.should render_template :index
      end
    end

    context 'given a logged in user' do
      before do
        @current_user = stub_login
      end
      it 'renders :index view' do
        get :index
        response.should render_template :index
      end
    end
  end

end