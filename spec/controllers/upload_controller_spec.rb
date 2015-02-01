require 'spec_helper'

describe UploadController do

  describe '#new' do
    before do
      @current_user = stub_login(double('current_user', id: 12))
    end
    it 'should assign @field_name render the new view' do
      Storage.stub(:new).with(:content_image).and_return 'an image storage'
      get :new, field: 'cloverfield', media_type: 'image', sub_folder: '42'
      assigns(:field_name).should eq 'cloverfield'
      assigns(:storage).should eq 'an image storage'
      assigns(:path_prefix).should eq "12/42"
      response.should render_template :new
    end
  end

  describe "POST 'sign_form'" do
    context 'given the browser supports xhr uploads' do
      before do
        request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (compatible; Windows; U; Windows NT 6.2; WOW64; en-US; rv:12.0) Gecko/20120403211507 Firefox/12.0'
      end

      it "returns the credentials and filename to sign the upload form, in a JSON format" do
        freeze_time Time.parse('01/01/2001')
        with_constants(:STORAGE => {photo: {provider: 'Google',
                                            access_key: 'MYID',
                                            secret_key:  'DONTTELLTHEM',
                                            conditions: {size: 6000000}}}) do
          post :sign_form, doc: {title: 'photo-12-5', extension: 'jpg'}, storage_name: 'photo', format: :json
          h = JSON.parse(response.body)
          h['policy'].should eq 'eyJleHBpcmF0aW9uIjoiMjAwMC0xMi0zMVQyMzowNTowMFoiLCJjb25kaXRpb25zIjpbWyJzdGFydHMtd2l0aCIsIiRrZXkiLCJwaG90by0xMi01Il0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LFsic3RhcnRzLXdpdGgiLCIkQ29udGVudC1UeXBlIiwiaW1hZ2UvIl0sWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsMCw2MDAwMDAwXV19'
          h['signature'].should eq 'utm5R3po5803Is6swnOkmWslyjU='
          h['key'].should eq 'photo-12-5_2000-12-31_11-00-00.jpg'
        end
      end
    end

    context 'given the browser DOES NOT support xhr uploads' do
      before do
        controller.stub(:reject_old_browsers).and_return true
        request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; Media Center PC 4.0; SLCC1; .NET CLR 3.0.04320)'
      end

      it "returns the credentials and filename with additional iframe specific param" do
        freeze_time Time.parse('01/01/2001')
        with_constants(:STORAGE => {avatar: { provider: 'AWS',
                                             access_key: 'MYID',
                                             secret_key:  'DONTTELLTHEM',
                                             conditions: {size: 3000000}}}) do
          post :sign_form, doc: {title: 'Avatar-12', extension: 'gif'}, storage_name: 'avatar', format: :json
          h = JSON.parse(response.body)
          h['policy'].should eq 'eyJleHBpcmF0aW9uIjoiMjAwMC0xMi0zMVQyMzowNTowMFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOm51bGx9LFsic3RhcnRzLXdpdGgiLCIka2V5IiwiQXZhdGFyLTEyIl0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LFsic3RhcnRzLXdpdGgiLCIkQ29udGVudC1UeXBlIiwiaW1hZ2UvIl0sWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsMCwzMDAwMDAwXSx7InN1Y2Nlc3NfYWN0aW9uX3JlZGlyZWN0IjoiaHR0cDovL3Rlc3QuaG9zdC9hcHAvdXBsb2FkL3VwbG9hZF9kb25lIn1dfQ=='
          h['signature'].should eq 'CYdb/FInxn5BGiNvgrU6Boh6vuo='
          h['key'].should eq 'Avatar-12_2000-12-31_11-00-00.gif'
        end
      end
    end
  end

  describe "GET 'upload_done'" do
    it "returns http success and a blank view" do
      get 'upload_done'
      response.should be_success
      response.body.should eq 'done'
    end
  end

end