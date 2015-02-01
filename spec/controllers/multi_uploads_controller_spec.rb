require 'spec_helper'

describe MultiUploadsController do

  describe '#new' do
    before do
      stub_login(double('current_user', id: 12))
    end
    it 'assigns the given sub_folder (used for path prefix) and render new' do
      get :new, sub_folder: '34'
      assigns(:sub_folder).should eq '34'
      response.should render_template :new
    end
  end
end