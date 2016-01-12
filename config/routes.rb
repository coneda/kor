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
  resources :tags, :only => :index
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
      get 'duplicate'
      get 'gallery'
      get 'recent'
      get 'invalid'
      get 'isolated'
    end
    
    member do
      get 'images'
      get 'metadata'
      get 'other_collection'
    end
  end
  resources :relationships, :except => [:index]
  resources :collections do
    collection do
      get 'edit_personal'
    end
    member do
      get 'edit_merge'
      put 'merge'
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

  match '/errors/:action', :controller => 'errors', :via => :get
  match '/downloads/:uuid', :to => 'downloads#show', :via => :get
  match 'content_types/:content_type_group/:content_type.gif', :to => 'media#dummy', :as => :media_dummy, :content_type => /[a-z0-9\.\-]+/, :via => :get
  
  scope '/media', :controller => 'media' do
    match 'maximize/:id', :action => 'show', :style => 'normal', :as => :maximize_medium, :via => :get
    match 'transform/:id/:transformation', :action => 'transform', :as => :transform_medium, :via => :get
    match ':id', :action => 'view', :as => :view_medium, :via => :get
    match 'images/:style/:id_part_01/:id_part_02/:id_part_03/:attachment.:style_extension', :action => 'show', :as => :medium, :via => :get
    match 'download/:style/:id', :action => 'download', :as => :download_medium, :via => :get
  end

  controller 'authentication' do
    match '/authentication/denied', :action => 'denied', :as => :denied, :format => :html, :via => :get
    match '/authenticate', :action => 'login', :via => :post
    match '/login', :action => 'form', :as => :login, :via => :get
    match '/logout', :action => 'logout', :as => :logout, :via => :get
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
      match 'login', :to => 'public#login', :via => :post
      match 'logout', :to => 'public#logout', :via => :get
      match 'info', :to => 'public#info', :via => :get
      
      resources :entities, :only => :show do
        member do
          get :relationships
          get :deep_media
        end
      end
      resources :ratings, :except => [:edit, :update]
    end
  end

  scope "tpl", :module => "tpl", :via => :get do
    resources :entities, :only => [:show] do
      collection do
        get :multi_upload
        get :isolated
        get :selector
      end
    end

    match "denied", :action => "denied"
    match "pagination", :action => "pagination"
    match "relation", :action => "relation"
    match "media_relation", :action => "media_relation"
    match "relationship", :action => "relationship"
    
    match "relationships/form", :to => "relationships#form"
    match "relations/selector", :to => "relations#selector"
  end

end
