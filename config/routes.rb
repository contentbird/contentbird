require 'resque/server'

Contentbird::Application.routes.draw do

  https_constraint = (Rails.env.production? ? {protocol: 'https://'} : {})
  http_catchall    = (Rails.env.production? ? {protocol: 'http://'}  : -> (params, request) {false})

  namespace :api, path: "api", constraints: https_constraint do
    scope module: :v2, constraints: ApiConstraints.new(version: 2) do
      resources :channel_info, only: [:show]
    end
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :channel_info, only: [:show]
      get  'home/contents'                        => 'home_contents#index',     as: 'home_contents'
      get  'sections/:section_slug/contents'      => 'section_contents#index',  as: 'section_contents'
      post 'sections/:section_slug/contents'      => 'section_contents#create'
      get  'sections/:section_slug/contents/new'  => 'section_contents#new',    as: 'new_section_content'
      get  'sections/:section_slug/contents/:id'  => 'section_contents#show',   as: 'section_content'
      resources :contents, only: [:index, :show]
    end
  end

  namespace :admin, path: '/pastouch', constraints: https_constraint do
    mount Resque::Server, at: '/jobs', as: 'jobs'
    get '/' => 'monitoring#index', as: :root
    resources :users, only: [:index, :show] do
      member do
        get :become
      end
    end
    get '/metrics' => 'metrics#index'
  end

  # Public website
  root 'home#index'
  get '/about'   => 'home#about'
  get '/privacy' => 'home#privacy'
  get '/terms'   => 'home#terms'
  get '/styleguide' => 'home#styleguide'
  resources :leads,       only: [:new, :create]

  # oauth callbacks
  match 'auth/:provider/callback', to: 'social_channels#new', via: [:get, :post]
  get   'auth/failure',            to: 'social_channels#fail'

  #main app, https only
  scope '/app', constraints: https_constraint do

    resource :api_explorer, only: [:show] do
      post :select
      post :run
    end

    resources :invitations, only: [:create]

    devise_for :users, class_name: 'CB::Core::User', controllers: { registrations: "registrations" }

    #user_setup : tunnel after sign up
    get    'users/setup'                          => 'user_setup#new',  as: :new_user_setup
    delete 'users/setup/website_channel'          => 'user_setup#cancel_website_channel', as: :cancel_website_channel
    delete 'users/setup/social_channel/:provider' => 'user_setup#cancel_social_channel',  as: :cancel_social_channel

    resources :content_types
    resources :publications, only: [:index, :create, :destroy] do
      member do
        get :show_expiration
        put :update_expiration
      end
    end

    resources :contents do
      post :markdown_preview, on: :collection
    end

    resources :channels, :social_channels, :api_channels, :messaging_channels do
      member do
        get  :check_credentials
        get  :reset_access_token
        post :open
        post :close
      end
    end

    resources :contacts, only: [:create]

    get  "channel_unsubscriptions/:channel_id/new" => "channel_unsubscriptions#new",    as: :new_channel_unsubscription
    post "channel_unsubscriptions/:channel_id"     => "channel_unsubscriptions#create", as: :channel_unsubscription

    # ajax direct_to_cloud upload
    post "upload/sign_form"
    get "upload/upload_done"
    get "upload/new", as: 'new_upload'
    resource :multi_upload, only: [:new, :create]

    #mock storage and image resizing in the cloud
    unless Rails.env.production?
      post "storage_mock/image"                                 => "storage_mock#upload_image"
      get  "storage_mock/image/:key"                            => "storage_mock#download_image", constraints: {key: /.*/}
      get  "storage_mock/channel/channels/css/:channel_id/:key" => "storage_mock#download_css"

      get "resizer_mock/resize_image"                           => "resizer_mock#resize_image", as: :resize_image
    end

    get '/' => 'dashboard#index', as: :dashboard

    resource :announcement, only: [:show] do
      get :close
    end

    get '/help/markdown' => 'help#markdown', as: :markdown_help
  end

  # catch all /app and /pastouch without https and redirect to same url using https
  match "app(/*path)",      constraints: http_catchall, via: [:get], to: redirect { |params, request| "https://" + request.host_with_port + request.fullpath }
  match "pastouch(/*path)", constraints: http_catchall, via: [:get], to: redirect { |params, request| "https://" + request.host_with_port + request.fullpath }
end