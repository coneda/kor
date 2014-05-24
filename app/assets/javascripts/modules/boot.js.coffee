angular.module('kor', []).config([ 
  "$httpProvider", 
  (httpProvider) ->
    #console.log "configuring"

    httpProvider.responseInterceptors.push [
      "$q", "korFlash",
      (q, korFlash) ->
        (promise) ->
          promise.then (response) ->
            if m = response.headers('X-Message-Error')
              korFlash.error = m

            if m = response.headers('X-Message-Notice')
              korFlash.notice = m

            response

    ]
  ]
).run([->
  #console.log "running"
]).controller('korSessionCtrl', ['$scope', 'korData', 'korFlash', (scope, korData, korFlash) ->
  scope.$on 'kor-session-load-complete', -> scope.info = korData.info
    
  scope.history_available = ->
    if scope.info
      scope.info.session.current_history.length > 0
    else
      false
  
  scope.toggle_session_panel = ->
    scope.info.session.show_panel = !scope.info.session.show_panel
    korData.toggle_session_panel scope.info.session.show_panel
    
  scope.fully_loaded = ->
    korData.entity && korData.info

  scope.flash_error = -> korData.error()
  scope.flash_notice = -> korData.notice()

  korData.session_load()
  
]).controller('korEntitiesShowCtrl', ['$scope', 'korData', (scope, korData) ->

  scope.$on 'kor-initial-load-complete', ->
    scope.entity = korData.entity
    
  scope.$on 'kor-deep-media-load-complete', (event, relationship, data, page) ->
    relationship.media = []

    row = []
    for r in data.relationships
      if row.length == 3
        relationship.media.push row
        row = []

      row.push r.entity

    if row.length > 0
      row.push null while row.length < 3
      relationship.media.push row

    relationship.media_page = page
    
  scope.$on 'kor-relation-load-complete', (event, relation, data, page) ->
    relation.relationships = data.relationships
    relation.page = page

  scope.page_deep_media = (relationship, page = 1, event) ->
    scope.current_deep_relationship = relationship
    korData.deep_media_load(relationship, page)

    event.preventDefault() if event

  scope.show_link = (link) ->
    if link.header
      result = false

      for k, v of link.links
        result = true

      result
    else
      !!link[1]

    
  scope.page_relation = (relation, page = 1, event) ->
    korData.relation_load(relation, page)
    event.preventDefault() if event
    
  scope.page_media_relation = (relation, page = 1, event) ->
    korData.media_relation_load(relation, page)
    event.preventDefault() if event
    
  scope.switch_relation = (relation, event) ->
    for r in relation.relationships
      scope.switch_relationship_panel(r, true, !relation.visible)
    
    relation.visible = !relation.visible
    event.preventDefault() if event

  scope.total_relation_pages = (relation) -> relation.total_pages ||= Math.ceil(relation.amount / 10)
    
  scope.switch_relationship_panel = (relationship, force = false, value = null, event) ->
    if force
      if value
        relationship.total_media_pages = Math.floor(relationship.total_media / 12) + 1
        if !relationship.media || relationship.media.length == 0
          scope.page_deep_media(relationship)
        relationship.visible = true
      else
        relationship.visible = false
    else
      if relationship.visible
        relationship.visible = false
      else
        relationship.total_media_pages = Math.floor(relationship.total_media / 12) + 1
        if !relationship.media || relationship.media.length == 0
          scope.page_deep_media(relationship) 
        relationship.visible = true

    event.preventDefault() if event
  
  scope.in_clipboard = ->
    if korData.info && korData.entity
      korData.info.session.clipboard ||= []
      korData.info.session.clipboard.indexOf(korData.entity.id) != -1
    else
      false
      
  scope.allowed_to = (policy, object = null) ->
    if korData.info && korData.entity
      object ||= korData.entity.collection_id
      korData.info.session.user.auth.collections[policy] ||= []
      korData.info.session.user.auth.collections[policy].indexOf(object) != -1
    else
      false
      
  scope.allowed_to_any = (policy) ->
    if korData.info
      korData.info.session.user.auth.collections[policy].length != 0
    else
      false

  scope.visible_entity_fields = ->
    if korData.entity
      korData.entity.fields.filter (field) ->
        field.value && field.settings.show_on_entity == "1"
    else
      []

  scope.authority_groups = ->
    if scope.entity
      @authority_groups_with_ancestry ||= for group in scope.entity.authority_groups
        result = {
          name: group.name
          ancestry: []
          id: group.id
        }
        category = group.authority_group_category

        while category
          result.ancestry.unshift category.name
          category = category.parent

        result

  scope.submit = (event) ->
    link = $(event.currentTarget)
    form = link.parents('form')
    confirm = link.data('confirm')

    if confirm
      if window.confirm(confirm)
        form.submit()
    else
      form.submit()
      
    event.preventDefault()
    event.stopPropagation()

  korData.initial_load()
]).service('korFlash', [ ->
  service = {

  }
]).service('korData', ['$rootScope', '$location', '$http', (rootScope, location, http) ->
  service = {
    entity: null
    session: null

    error: -> if service.info then service.info.session.flash.error else null
    notice: -> if service.info then service.info.session.flash.notice else null
    
    initial_load: () ->
      id = location.absUrl().split("/")[4]
      http(method: 'get', url: "/api/1.0/entities/#{id}/show_full").success((data) =>
        this.entity = data
        rootScope.$broadcast "kor-initial-load-complete"
      )
      
    deep_media_load: (relationship, page = 1) ->
      page = Math.min(relationship.total_media_pages, page)
      page = Math.max(1, page)

      request = {
        method: 'get'
        url: "/api/1.0/entities/#{relationship.entity.id}/relationships"
        params: {'page': page - 1, media: true, limit: 12}
      }

      http(request).success((data) =>
        rootScope.$broadcast "kor-deep-media-load-complete", relationship, data, page
      )
    
    relation_load: (relation, page = 1) ->
      page = Math.min(relation.total_pages, page)
      page = Math.max(1, page)
      
      http(method: 'get', url: "/api/1.0/entities/#{service.entity.id}/relationships", params: {'page': page - 1, name: relation.name}).success((data) =>
        rootScope.$broadcast "kor-relation-load-complete", relation, data, page
      )
    
    media_relation_load: (relation, page = 1) ->
      page = Math.min(relation.total_pages, page)
      page = Math.max(1, page)

      http(method: 'get', url: "/api/1.0/entities/#{service.entity.id}/relationships", params: {'page': page - 1, name: relation.name, media: true}).success((data) =>
        rootScope.$broadcast "kor-relation-load-complete", relation, data, page
      )

    session_load: ->
      http(method: 'get', url: "/api/1.0/info", type: "json").success( (data) =>
        this.info = data
        rootScope.$broadcast "kor-session-load-complete", data
      )
      
    toggle_session_panel: (state) ->
      state = if state then 'show' else 'hide'
      http(method: 'get', url: "/tools/session_info", params: {show: state})

  }
]).service('korTranslate', ["korData", (korData) ->
  return {
    translate: (input, options = {}) ->
      try
        options.count ||= 1
        parts = input.split(".")
        result = korData.info.translations[korData.info.locale]
        
        for part in parts
          result = result[part]
        
        count = if options.count == 1 then 'one' else 'other'
        result = result[count] || result
        
        for key, value of options.interpolations
          regex = new RegExp("%\{#{key}\}", "g")
          value = tvalue if (tvalue = this.translate(value)) != value
          result = result.replace regex, tvalue
          
        result
      catch error
        ""
  }
]).filter('translate', ["korTranslate", (korTranslate) ->
  return (input, options = {}) -> korTranslate.translate(input, options)
]).filter('capitalize', [ ->
  return (input) ->
    try
      input[0..0].toUpperCase() + input[1..-1]
    catch erro
      ""
]).filter('strftime', [ ->
  return (input, format) ->
    try
      if !(input instanceof Date)
        input = new Date(input)
        
      result = new FormattedDate(input)
      result.strftime format
    catch error
      ""
]).filter('human_bool', [ ->
  return (input) ->
    if input then 'ja' else 'nein'
]).filter('human_size', [ ->
  return (input) ->
    if input < 1024
      return "#{input} B"
    if input < 1024 * 1024
      return "#{Math.round(input / 1024 * 100) / 100} KB"
    if input < 1024 * 1024 * 1024
      return "#{Math.round(input / (1024 * 1024) * 100) / 100} MB"
    if input < 1024 * 1024 * 1024 * 1024
      return "#{Math.round(input / (1024 * 1024 * 1024) * 100) / 100} GB"
]).filter('image_size', [ ->
  return (input, size) ->
    if input then input.replace(/preview/, size) else ""
])

