class OaiPmhVerbConstraint
  def initialize(verb)
    @verb = verb
  end

  def matches?(request)
    request.params[:verb] == @verb
  end
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'kor#index', as: 'root'
  get '/empty', to: 'kor#index' # dummy for testing

  get '/downloads/:uuid', to: 'downloads#show'
  get '/resolve(/:kind)/:id', to: 'identifiers#resolve'
  get '/env_auth', to: 'session#env_auth'

  scope '/media', controller: 'media', defaults: {format: 'json'} do
    patch 'transform/:id/:transformation/:operation', action: 'transform'
    get(
      ':disposition/:style/:id_part_01/:id_part_02/:id_part_03/:attachment.:style_extension',
      action: 'show',
      constraints: {disposition: /images|download/}
    )
  end

  get '/api', to: 'kor#api'

  defaults format: 'json' do
    get 'fields/types', to: 'fields#types'

    scope controller: 'session' do
      get 'session', action: 'show'
      post 'login', action: 'create'
      delete 'logout', action: 'destroy'
      post 'account-recovery', action: 'recovery'
    end

    scope controller: 'kor' do
      get 'translations', action: 'translations'
      get 'info', action: 'info'
      get 'statistics', action: 'statistics'
    end

    resource 'settings', only: ['show', 'update']

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
        post 'add', action: 'add_to'
        post 'remove', action: 'remove_from'
      end
    end

    resources :user_groups, except: ['new', 'edit'] do
      member do
        get 'download_images'
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
      member do
        patch 'merge'
        patch 'entities'
      end
    end

    resources :credentials, except: ['edit', 'new']

    resources :entities do
      collection do
        get 'multi_upload'
        post 'merge'
        post 'existence'
        delete 'mass_destroy'
      end

      member do
        get 'metadata'
        patch 'update_tags'
        post 'mass_relate'
      end

      resources :relations, only: [:index]
    end
  end

  scope 'mirador', controller: 'iiif/media' do
    root action: 'index', as: 'mirador'

    defaults format: 'json' do
      get ':id', action: 'show', as: 'iiif_manifest'

      # TODO: why is this here? there are no actions for this
      get ':id/sequence', action: 'sequence', as: 'iiif_sequence'
      get ':id/canvas', action: 'sequence', as: 'iiif_canvas'
      get ':id/image', action: 'sequence', as: 'iiif_image'
    end
  end

  scope 'oai-pmh', format: 'xml', as: 'oai_pmh', via: [:get, :post] do
    ['entities', 'relationships', 'kinds', 'relations'].each do |res|
      scope controller: "oai_pmh/#{res}", defaults: {format: 'xml'} do
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
    post 'import', action: 'import'
  end
end
