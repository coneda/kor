kor.service('korData', ['$rootScope', '$location', '$http', (rootScope, location, http) ->
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
        if service.info
          service.fully_loaded = true
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
        if service.entity
          service.fully_loaded = true
      )
      
    toggle_session_panel: (state) ->
      state = if state then 'show' else 'hide'
      http(method: 'get', url: "/tools/session_info", params: {show: state})

    fully_loaded: false

  }
])