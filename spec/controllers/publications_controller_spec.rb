require 'spec_helper'

describe PublicationsController do

  before do
    @current_user = stub_login
    CB::Manage::Publication.stub(:new).with(@current_user).and_return(@service = double('publication service'))
    request.env['HTTP_REFERER'] = 'previous page'
  end

  describe '#index' do
    it 'asks the publication service for the given content publications, and renders the index view' do
      @service.stub(:list).with('37').and_return({'chan1' => nil, 'chan2' => 'pub2'})

      get :index, content_id: '37', format: 'js'
      assigns(:content_id).should eq '37'
      assigns(:publications).should eq({'chan1' => nil, 'chan2' => 'pub2'})
      response.should render_template :index
    end
  end

  describe '#create' do
    context 'given the publication was successful and created a new section id 13' do
      it 'tells the publication service to publish the content matching the given content_id on the channel matching the given channel_id and returns json data' do
        @service.should_receive(:publish).with('37', '42').and_return([true, pub = double('publication', id: 12, to_param: '12', permalink: 'cb.me_url_to_publication', channel_id: 13).as_null_object, true])
        pub.stub(:content).and_return(double('content', publications_count: 2))

        post :create, publication: {content_id: '37', channel_id: '42'}, format: 'json'

        response.should be_success
        message = "This channel did not have a section for this format, so we created it for you. Click <a href=\"#{edit_api_channel_path(13)}#bottom\">here</a> to tune this new section"
        response.body.should eq({publication: { id: 12,
                                                permalink: 'cb.me_url_to_publication'},
                                                unpublish_path: publication_path('12'),
                                                show_expiration_path: show_expiration_publication_path('12'),
                                                publications_count: 2,
                                                new_section_created: true,
                                                new_section_message: message}.to_json)
      end
    end
    context 'given the publication was successful and DID NOT create a new section' do
      it 'tells the publication service to publish the content matching the given content_id on the channel matching the given channel_id and returns json data' do
        @service.should_receive(:publish).with('37', '42').and_return([true, pub = double('publication', id: 12, to_param: '12', permalink: 'cb.me_url_to_publication', channel_id: 13).as_null_object, false])
        pub.stub(:content).and_return(double('content', publications_count: 2))

        post :create, publication: {content_id: '37', channel_id: '42'}, format: 'json'

        response.should be_success
        response.body.should eq({publication: { id: 12,
                                                permalink: 'cb.me_url_to_publication'},
                                                unpublish_path: publication_path('12'),
                                                show_expiration_path: show_expiration_publication_path('12'),
                                                publications_count: 2,
                                                new_section_created: false,
                                                new_section_message: nil }.to_json)
      end
    end
    it 'it returns a json error msg and a status 500 if publication fails' do
      @service.should_receive(:publish).with('37', '42').and_return([false, double('publication').as_null_object, false])

      post :create, publication: {content_id: '37', channel_id: '42'}, format: 'json'

      response.should be_error
      response.body.should eq({error: {msg: 'Sorry, we could not publish your content'}}.to_json)
    end
  end

  describe '#destroy' do
    it 'asks the service to unpublish publication matching the given id and renders json data' do
      @service.should_receive(:unpublish).with('37').and_return [true, pub = double('publication').as_null_object, false]
      pub.stub(:content).and_return(double('content', publications_count: 1))

      delete :destroy, id: '37'

      response.should be_success
      response.body.should eq({publish_path: publications_path, publications_count: 1, message: nil}.to_json)
    end

    it 'adds a user message to the json response if the user needs to manually unpublish his content from the provider' do
      @service.should_receive(:unpublish).with('37').and_return [true, pub = double('publication').as_null_object, true]
      pub.stub(:content).and_return(double('content', publications_count: 1))

      delete :destroy, id: '37'

      response.should be_success
      response.body.should eq({publish_path: publications_path, publications_count: 1, message: 'Provider does not allow us to remove your content, do it yourself'}.to_json)
    end

    it 'renders a json error message with a status 500 if destruction failed' do
      @service.should_receive(:unpublish).with('37').and_return [false, 'my publication', false]

      delete :destroy, id: '37'

      response.should be_error
      response.body.should eq({error: {msg: 'Sorry, we could not unpublish your content'}}.to_json)
    end
  end

  describe '#show_expiration' do
    it 'assigns @publication to the publication matching the given id and renders show_expiration view' do
      @service.stub(:find).with('37').and_return('a publication')

      get :show_expiration, id: '37'

      assigns(:publication).should eq 'a publication'
      response.should render_template(:show_expiration)
    end
  end

  describe '#update_expiration' do
    before do
      @now = freeze_time
    end
    it 'tells the service to set the expiration date of the publication matching the given id, and returns the result as Json' do
      @service.stub(:set_expiration).with('37', 'never').and_return([true, {expire_at: @now }])

      put :update_expiration, id: '37', expire_in: 'never'

      response.body.should eq({updated: true, expire_at: @now }.to_json)
    end
    context 'given service fails to set the expiration date' do
      it 'returns the false and the error message as Json' do
        @service.stub(:set_expiration).with('37', 'never').and_return([false, {error: {msg: 'sorry boss'} }])

        put :update_expiration, id: '37', expire_in: 'never'

        response.body.should eq({updated: false, error: {msg: 'sorry boss'} }.to_json)
      end
    end
  end
end