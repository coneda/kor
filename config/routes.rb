class OaiPmhVerbConstraint
  def initialize(verb)
    @verb = verb
  end

  def matches?(request)
    request.params[:verb] == @verb
  end
end

Rails.application.routes.draw do

  get '/blaze', :to => 'static#blaze', :as => :web

  match 'resolve(/:kind)/:id', :to => 'identifiers#resolve', via: :get
  
  root :to => 'main#welcome'
  match '/welcome', :to => 'main#welcome', :via => :get
  
  match '/authentication/form' => redirect('/login'), :via => :get
  
  controller 'inplace' do
    match '/kor/inplace/tags', :action => 'tag_list', :via => :get
    match '/kor/inplace/tags/entities/:entity_id/tags', :action => 'update_entity_tags', :via => :post
  end
  
  resources :exception_logs, :only => :index do
    collection do
      get 'cleanup'
    end
  end
  resources :kinds do
    resources :fields, :except => 'show'
    resources :generators
  end
  resources :relations do
    collection do
      get 'names'
    end
  end
  resources :entities do
    collection do
      get 'multi_upload'
      get 'gallery'
      get 'recent'
      get 'invalid'
      get 'isolated'
      get 'recently_created'
      get 'recently_visited'
    end
    
    member do
      get 'metadata'
    end

    scope format: :json do
      resources :relations, only: [:index]
      resources :relationships, only: [:index, :show], controller: 'directed_relationships'
    end
  end

  scope format: :json do
    resources :relationships, only: [:index, :show], controller: 'directed_relationships'
    resources :relationships, only: [:create, :update, :destroy]
  end
  
  resources :collections do
    collection do
      get 'edit_personal'
    end
    member do
      get 'edit_merge'
      patch 'merge'
    end
  end
  resources :credentials
  resources :authority_group_categories
  resources :system_groups
  resources :user_groups do
    member do
      get 'download_images'
      get 'share'
      get 'unshare'
      get 'show_shared'
      get 'add_to'
      get 'remove_from'
      get 'mark'
    end
    
    collection do
      get 'shared'
    end
  end
  resources :authority_groups, :except => [ :index ] do
    member do
      get 'download_images'
      get 'edit_move'
      get 'add_to'
      get 'remove_from'
      get 'mark'
    end
  end
  resources :publishments do
    member do
      get 'extend'
    end
  end
  match '/pub/:user_id/:uuid', :to => 'publishments#show', :as => :show_publishment, :via => :get
  match '/edit_self', :to => 'users#edit_self', :via => :get
  match '/update_self', :to => 'users#update_self', :via => :patch
  resources :users do
    member do
      get 'reset_password'
      get 'accept_terms'
      get 'edit_self'
      get 'reset_login_attempts'
      get 'new_from_template'
    end
  end

  match '/downloads/:uuid', :to => 'downloads#show', :via => :get
  
  scope '/media', :controller => 'media' do
    match 'maximize/:id', :action => 'show', :style => 'normal', :as => :maximize_medium, :via => :get
    match 'transform/:id/:transformation', :action => 'transform', :as => :transform_medium, :via => :get
    match ':id', :action => 'view', :as => :view_medium, :via => :get
    match 'images/:style/:id_part_01/:id_part_02/:id_part_03/:attachment.:style_extension', :action => 'show', :as => :medium, :via => :get
    match 'download/:style/:id', :action => 'download', :as => :download_medium, :via => :get
  end

  controller 'authentication' do
    match '/authenticate', :action => 'login', :via => :post
    match '/env_auth', action: 'env_auth', via: :get
    match '/login', :action => 'form', :as => :login, :via => :get
    match '/login', :action => 'login', :via => :post
    match '/logout', :action => 'logout', :as => :logout, :via => [:get, :delete]
    match '/password_forgotten', :action => 'password_forgotten', :via => :get
    match '/password_reset', :action => 'personal_password_reset', :via => :post
  end
  
  match 'config/menu', :to => "config#menu", :via => :get
  match 'config/general', :to => "config#general", :via => :get, :as => "config"
  match 'config/save_general', :to => "config#save_general", :via => :post
  
  match '/mark', :to => 'tools#mark', :as => :put_in_clipboard, :via => [:get, :delete]
  match '/mark_as_current/:id', :to => 'tools#mark_as_current', :as => :mark_as_current, :via => [:get, :delete]
  
  scope '/tools', :controller => 'tools' do
    match 'session_info', :action => 'session_info', :via => :get
    match 'clipboard', :action => 'clipboard', :via => :get
    match 'statistics', :action => 'statistics', :via => :get
    match 'credits', :action => 'credits', :via => :get
    match 'credits/:id', :action => 'credits', :via => :get
    match 'groups_menu', :action => 'groups_menu', :via => :get
    match 'input_menu', :action => 'input_menu', :via => :get
    match 'relational_form_fields', :action => 'relational_form_fields', :via => :get
    match 'dataset_fields', :action => 'dataset_fields', :via => :get
    match 'clipboard_action', :action => 'clipboard_action', :via => :post
    match 'new_clipboard_action', :action => 'new_clipboard_action', :via => [:get, :post]
    match 'history', :action => 'history', :via => "post"
    
    match 'add_media/:id', :action => 'add_media', :via => :get
  end
  
  scope 'static', :controller => 'static' do
    match 'legal', :action => 'legal', :via => :get
    match 'contact', :action => 'contact', :via => :get
    match 'about', :action => 'about', :via => :get
    match 'help', :action => 'help', :via => :get
  end
  
  namespace 'api', :format => :json do
    scope ':version', :version => /[0-9\.]+/, :defaults => {:version => '1.0'} do
      match 'info', :to => 'public#info', :via => :get
    end

    scope 'oai-pmh', :format => :xml, :as => 'oai_pmh', :via => [:get, :post] do
      ['entities', 'relationships', 'kinds', 'relations'].each do |res|
        controller "oai_pmh/#{res}", :defaults => {:format => :xml} do
          match res, :to => "oai_pmh/#{res}#identify", :constraints => OaiPmhVerbConstraint.new('Identify')
          match res, :to => "oai_pmh/#{res}#list_sets", :constraints => OaiPmhVerbConstraint.new('ListSets')
          match res, :to => "oai_pmh/#{res}#list_metadata_formats", :constraints => OaiPmhVerbConstraint.new('ListMetadataFormats')
          match res, :to => "oai_pmh/#{res}#list_identifiers", :constraints => OaiPmhVerbConstraint.new('ListIdentifiers')
          match res, :to => "oai_pmh/#{res}#list_records", :constraints => OaiPmhVerbConstraint.new('ListRecords')
          match res, :to => "oai_pmh/#{res}#get_record", :constraints => OaiPmhVerbConstraint.new('GetRecord')
          match res, :to => "oai_pmh/#{res}#verb_error"
        end
      end
    end
  end

  scope "tpl", :module => "tpl", :via => :get do
    resources :entities, :only => [:show] do
      collection do
        get :multi_upload
        get :isolated
        get :gallery
      end
    end

    match "denied", :action => "denied"
  end

end
