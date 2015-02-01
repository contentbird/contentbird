require 'spec_helper'

describe APIExplorersController do

  before do
    CB::Client::Session.stub(:public_instance_methods).with(false).and_return [:key, :secret, :section_contents, :method2]
    CB::Client::Session.stub(:public_instance_method).with(:section_contents).and_return double('section_contents', parameters: [[:req, :section_slug], [:opt, :options]])
    CB::Client::Session.stub(:public_instance_method).with(:method2).and_return double('method2', parameters: [[:opt, :options]])
    controller.stub(:t).with('api_explorers.methods.section_contents').and_return('The first method')
    controller.stub(:t).with('api_explorers.methods.method2').and_return('The second method')
  end

  describe '#show' do
    it 'assigns the list of all available api actions and renders the explore view' do
      get :show

      assigns(:api_actions).should eq({'The first method' => 'section_contents', 'The second method' => 'method2'})
      assigns(:api_locale).should            eq 'test'
      response.should render_template(:explore)
    end
  end

  describe '#select' do
    it 'assigns @actions, @current_action, @api_key, @api_secret, @current_action_params and renders the explore view' do
      post :select, api_key: 'the key', api_secret: 'the secret', current_action: 'section_contents'

      assigns(:api_key).should               eq 'the key'
      assigns(:api_secret).should            eq 'the secret'
      assigns(:api_locale).should            eq 'test'
      assigns(:current_action).should        eq 'section_contents'
      assigns(:current_action_params).should eq [[:req, :section_slug]]
      response.should render_template(:explore)
    end
  end

  describe '#run' do
    it 'call API on current_action passing all the params and assigns @api_curl and @api_response and renders explore' do
      CB::Client::Session.stub(:new).with('the key', 'the secret', :fr, false).and_return(api_session = double('session'))
      api_session.stub(:section_contents).with('la-slug', context: [:the_context], page: nil, only_curl: true).and_return [true, 'curl -X whataver']
      api_session.stub(:section_contents).with('la-slug', context: [:the_context], page: nil).and_return                  [true, 'nice json']

      post :run, api_key: 'the key',
                 api_secret: 'the secret',
                 api_locale: 'fr',
                 current_action: 'section_contents',
                 api_params: {section_slug: 'la-slug'},
                 api_context: 'the_context'

      assigns(:api_key).should               eq 'the key'
      assigns(:api_secret).should            eq 'the secret'
      assigns(:api_locale).should            eq 'fr'
      assigns(:current_action).should        eq 'section_contents'
      assigns(:current_action_params).should eq [[:req, :section_slug]]

      assigns(:api_curl).should     eq 'curl -X whataver'
      assigns(:api_response).should eq 'nice json'

      response.should render_template(:explore)
    end
  end
end