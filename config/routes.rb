Kor::Application.routes.draw do

  match '/blaze', :to => 'static#blaze', :as => :web

  match '/by_uuid/:uuid', :to => 'entities#by_uuid'
  
  root :to => 'main#welcome'
  match '/welcome', :to => 'main#welcome'
  
  match '/authentication/form' => redirect('/login')
  
  controller 'inplace' do
    match '/kor/inplace/tags', :action => 'tag_list'
    match '/kor/inplace/tags/entities/:entity_id/tags', :action => 'update_entity_tags'
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
  resources :relations
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
  match '/pub/:user_id/:uuid', :to => 'publishments#show', :as => :show_publishment
  match '/edit_self', :to => 'users#edit_self'
  match '/update_self', :to => 'users#update_self'
  resources :users do
    member do
      get 'reset_password'
      get 'accept_terms'
      get 'edit_self'
      get 'reset_login_attempts'
      get 'new_from_template'
    end
  end

  match '/errors/:action', :controller => 'errors'  
  match '/downloads/:uuid', :to => 'downloads#show'
  match 'content_types/:content_type_group/:content_type.gif', :to => 'media#dummy', :as => :media_dummy, :content_type => /[a-z0-9\.\-]+/
  
  scope '/media', :controller => 'media' do
    match 'maximize/:id', :action => 'show', :style => 'normal', :as => :maximize_medium
    match 'transform/:id/:transformation', :action => 'transform', :as => :transform_medium
    match ':id', :action => 'view', :as => :view_medium
    match 'images/:style/:id_part_01/:id_part_02/:id_part_03/:attachment.:style_extension', :action => 'show', :as => :medium
    match 'download/:style/:id', :action => 'download', :as => :download_medium
  end

  controller 'authentication' do
    match '/authentication/denied', :action => 'denied', :as => :denied, :format => :html
    match '/authenticate', :action => 'login'
    match '/login', :action => 'form', :as => :login
    match '/logout', :action => 'logout', :as => :logout
    match '/password_forgotten', :action => 'password_forgotten'
    match '/password_reset', :action => 'personal_password_reset'
  end
  
  match 'config/:action', :controller => 'config', :as => :config
  
  match '/mark', :to => 'tools#mark', :as => :put_in_clipboard
  match '/mark_as_current/:id', :to => 'tools#mark_as_current', :as => :mark_as_current
  
  scope '/tools', :controller => 'tools' do
    match 'session_info', :action => 'session_info'
    match 'clipboard', :action => 'clipboard'
    match 'statistics', :action => 'statistics'
    match 'credits', :action => 'credits'
    match 'credits/:id', :action => 'credits'
    match 'groups_menu', :action => 'groups_menu'
    match 'input_menu', :action => 'input_menu'
    match 'relational_form_fields', :action => 'relational_form_fields'
    match 'dataset_fields', :action => 'dataset_fields'
    match 'clipboard_action', :action => 'clipboard_action'
    match 'new_clipboard_action', :action => 'new_clipboard_action'
    match 'history', :action => 'history', :via => "post"
    
    match 'add_media/:id', :action => 'add_media'
  end
  
  scope 'static', :controller => 'static' do
    match 'legal', :action => 'legal'
    match 'contact', :action => 'contact'
    match 'about', :action => 'about'
    match 'help', :action => 'help'
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

  scope 'api/1.0' do
    resources :relationships, :only => [:index]
  end

  match "api/kinds/:kind_id/entities", :to => "component_search#component_search"

  scope "tpl", :module => "tpl" do
    resources :entities, :only => [:show] do
      collection do
        get :multi_upload
        get :isolated
      end
    end

    match "denied", :action => "denied"
    match "pagination", :action => "pagination"
  end

end
