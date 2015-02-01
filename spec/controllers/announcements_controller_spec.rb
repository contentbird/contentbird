require 'spec_helper'

describe AnnouncementsController do
  before do
    @current_user = stub_login(OpenStruct.new(id: 3))
  end

  describe '#show' do
    it 'stores the current announcement code on the current_user, and redirects to the current announcement url' do
      with_constants  :ANNOUNCEMENT_CODE => 'test_announcement',
                      :ANNOUNCEMENT_URL  => 'http://monblog.com/announcement' do
        @current_user.should_receive(:announcement_clicked!).with('test_announcement')

        get :show

        response.should redirect_to('http://monblog.com/announcement')
      end
    end
  end

  describe '#close' do
    before do
      request.env["HTTP_REFERER"] = '/previous/page'
    end
    it 'stores the current announcement code on the current_user, and redirects to previous page' do
      with_constants  :ANNOUNCEMENT_CODE => 'test_announcement',
                      :ANNOUNCEMENT_URL  => 'http://monblog.com/announcement' do
        @current_user.should_receive(:announcement_clicked!).with('test_announcement')

        get :close

        response.should redirect_to '/previous/page'
      end
    end
  end
end