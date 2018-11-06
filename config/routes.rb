class OaiPmhVerbConstraint
  def initialize(verb)
    @verb = verb
  end

  def matches?(request)
    request.params[:verb] == @verb
  end
end

Rails.application.routes.draw do

  # get '/blaze', to: 'static#blaze', as: :web

  root to: 'kor#index', as: 'root'
  # get '/welcome', to: 'main#welcome'
  
  # get '/authentication/form' => redirect('/login')
  
  # controller 'inplace' do
  #   match '/kor/inplace/tags', action: 'tag_list', via: :get
  #   match '/kor/inplace/tags/entities/:entity_id/tags', action: 'update_entity_tags', via: :post
  # end
  
  # resources :exception_logs, only: 'index' do
  #   collection do
  #     get 'cleanup'
  #   end
  # end

  # resources :system_groups
  
  # match '/edit_self', to: 'users#edit_self', via: :get

  scope '/media', controller: 'media', defaults: {format: 'json'} do
    # match 'maximize/:id', action: 'show', style: 'normal', as: :maximize_medium, via: :get
    patch 'transform/:id/:transformation/:operation', action: 'transform'
    # match ':id', action: 'view', as: :view_medium, via: :get
    get(
      ':disposition/:style/:id_part_01/:id_part_02/:id_part_03/:attachment.:style_extension',
      action: 'show',
      constraints: {disposition: /images|download/}
    )
    # get 'download/:style/:id_part_01/:id_part_02/:id_part_03/:attachment.:style_extension', action: 'show'
    # match 'download/:style/:id', action: 'download', as: :download_medium, via: :get
  end

  # controller 'authentication' do
    # match '/authenticate', action: 'login', via: :post
    # match '/env_auth', action: 'env_auth', via: :get
    # match '/login', action: 'form', as: :login, via: :get
    # match '/login', action: 'login', via: :post
    # match '/logout', action: 'logout', as: :logout, via: [:get, :delete]
    # match '/password_forgotten', action: 'password_forgotten', via: :get
    # match '/password_reset', action: 'personal_password_reset', via: :post
  # end
  
  # match 'config/menu', to: "config#menu", via: :get
  # match 'config/general', to: "config#general", via: :get, as: "config"
  # match 'config/save_general', to: "config#save_general", via: :post
  
  # match '/mark', to: 'tools#mark', as: :put_in_clipboard, via: [:get, :delete]
  # match '/mark_as_current/:id', to: 'tools#mark_as_current', as: :mark_as_current, via: [:get, :delete]
  
  # scope '/tools', controller: 'tools' do
    # match 'clipboard', action: 'clipboard', via: :get
    # match 'statistics', action: 'statistics', via: :get
    # match 'credits', action: 'credits', via: :get
    # match 'credits/:id', action: 'credits', via: :get
    # match 'groups_menu', action: 'groups_menu', via: :get
    # match 'input_menu', action: 'input_menu', via: :get
    # match 'relational_form_fields', action: 'relational_form_fields', via: :get
    # match 'dataset_fields', action: 'dataset_fields', via: :get
    # match 'clipboard_action', action: 'clipboard_action', via: :post
    # match 'new_clipboard_action', action: 'new_clipboard_action', via: [:get, :post]
    # match 'history', action: 'history', via: "post"
    
    # match 'add_media/:id', action: 'add_media', via: :get
  # end

  get '/downloads/:uuid', to: 'downloads#show'
  get '/resolve(/:kind)/:id', to: 'identifiers#resolve'
  get '/env_auth', to: 'session#env_auth'

  defaults format: 'json' do
    # patch 'profile', to: 'users#update_profile'
    get 'fields/types', to: 'fields#types'
    # match 'clipboard', to: 'tools#clipboard', via: :get

    controller 'session' do
      get 'session', action: 'show'
      post 'login', action: 'create'
      delete 'logout', action: 'destroy'
      post 'account-recovery', action: 'recovery'
    end

    controller 'kor' do
      get 'translations', action: 'translations'
      get 'info', action: 'info'
      get 'statistics', action: 'statistics'
    end

    scope 'tools', controller: 'tools' do
      delete 'mass_delete', action: 'mass_delete'
    end

    resource 'settings', only: ['show', 'update']
    # match 'config', action: 'kor_config', via: 'get'

    # controller 'static' do
    #   match 'legal', action: 'legal', via: :get
    #   match 'contact', action: 'contact', via: :get
    #   match 'about', action: 'about', via: :get
    #   match 'help', action: 'help', via: :get
    # end

    resources :kinds, except: ['edit', 'new'] do
      resources :fields, except: ['edit', 'new', 'index']
      resources :generators, except: ['edit', 'new', 'index']
    end

    resources :relations, except: [:new, :edit] do
      collection do
        get 'names'
      end
      member do
        put 'invert'
        post 'merge'
      end
    end

    resources :relationships, only: ['index', 'show'], controller: 'directed_relationships'
    resources :relationships, only: ['create', 'update', 'destroy']

    resources :authority_group_categories, except: ['new', 'edit'] do
      collection do
        get :flat
      end
    end
    resources :authority_groups, except: ['new', 'edit'] do
      member do
        get 'download_images'
        # get 'edit_move'
        # get 'mark'
        post 'add', action: 'add_to'
        post 'remove', action: 'remove_from'
      end
    end
    
    resources :user_groups do
      member do
        get 'download_images'
        # get 'show_shared'
        # get 'mark'

        patch 'share'
        patch 'unshare'
        post 'add', action: 'add_to'
        post 'remove', action: 'remove_from'
      end
      
      collection do
        get 'shared'
      end
    end

    resources :publishments, except: ['new', 'edit', 'show'] do
      member do
        patch 'extend', action: 'extend_publishment'
      end
    end
    get '/publishments/:user_id/:uuid', to: 'publishments#show'

    resources :users, except: ['new', 'edit'] do
      member do
        patch 'reset_login_attempts'
        patch 'reset_password'
      end
      collection do
        patch 'accept_terms'
        patch 'me', action: 'update_me'
        get 'me'
      end
    end

    resources :collections, except: ['edit', 'new'] do
      # collection do
      #   get 'edit_personal'
      # end
      member do
        # get 'edit_merge'
        patch 'merge'
      end
    end
    resources :credentials, except: ['edit', 'new']

    resources :entities do
      collection do
        get 'multi_upload'
        get 'gallery'
        get 'recent'
        get 'invalid'
        get 'isolated'
        get 'random'
        get 'recently_created'
        get 'recently_visited'

        post 'merge'
        post 'existence'
      end
      
      member do
        get 'metadata'
        patch 'update_tags'
        post 'mass_relate'
      end

      resources :relations, only: [:index]
      # resources :relationships, only: [:index, :show], controller: 'directed_relationships'
    end
  end

  scope 'mirador', controller: 'api/iiif/media' do
    root action: 'index', as: 'mirador'

    defaults format: 'json' do
      get ':id', action: 'show', as: 'iiif_manifest'

      # TODO: why is this here? there are no actions for this
      get ':id/sequence', action: 'sequence', as: 'iiif_sequence'
      get ':id/canvas', action: 'sequence', as: 'iiif_canvas'
      get ':id/image', action: 'sequence', as: 'iiif_image'
    end
  end
  
  namespace 'api' do
    # scope ':version', version: /[0-9\.]+/, defaults: {version: '1.0'} do
      # match 'info', to: 'public#info', via: :get
      # get 'profile', to: 'users#edit_self'
    # end

    scope 'oai-pmh', format: 'xml', as: 'oai_pmh', via: [:get, :post] do
      ['entities', 'relationships', 'kinds', 'relations'].each do |res|
        controller "oai_pmh/#{res}", defaults: {format: 'xml'} do
          match res, to: "oai_pmh/#{res}#identify", constraints: OaiPmhVerbConstraint.new('Identify')
          match res, to: "oai_pmh/#{res}#list_sets", constraints: OaiPmhVerbConstraint.new('ListSets')
          match res, to: "oai_pmh/#{res}#list_metadata_formats", constraints: OaiPmhVerbConstraint.new('ListMetadataFormats')
          match res, to: "oai_pmh/#{res}#list_identifiers", constraints: OaiPmhVerbConstraint.new('ListIdentifiers')
          match res, to: "oai_pmh/#{res}#list_records", constraints: OaiPmhVerbConstraint.new('ListRecords')
          match res, to: "oai_pmh/#{res}#get_record", constraints: OaiPmhVerbConstraint.new('GetRecord')
          match res, to: "oai_pmh/#{res}#verb_error"
        end
      end
    end

    scope 'wikidata', format: 'json', controller: 'wikidata' do
      post 'preflight', action: 'preflight'
      post 'import', action: 'import'
    end
  end

  # scope "tpl", module: "tpl", via: :get do
  #   resources :entities, only: [:show] do
  #     collection do
  #       get :multi_upload
  #       get :isolated
  #       get :gallery
  #     end
  #   end

  #   match "denied", action: "denied"
  # end

end
