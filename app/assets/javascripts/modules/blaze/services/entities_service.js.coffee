kor.service "entities_service", [
  "$http",
  (http) ->
    service = {
      index: (params = {}) ->
        http(
          method: 'get'
          url: '/entities.json'
          params: params
        )
      isolated: (params = {}) ->
        http(
          method: 'get'
          url: "/entities/isolated"
          headers: {accept: 'application/json'}
          params: params
        )

      gallery: (params = {}) ->
        http(
          method: 'get'
          url: '/entities/gallery'
          headers: {accept: 'application/json'}
          params: params
        )
      recently_created: (params = {}) ->
        http(
          method: 'get'
          headers: {accept: 'application/json'}
          url: "/entities/recently_created"
          params: params
        )
      recently_visited: (params = {}) ->
        http(
          method: 'get'
          headers: {accept: 'application/json'}
          url: "/entities/recently_visited"
          params: params
        )

      show: (id) ->
        http(
          method: 'get'
          headers: {accept: 'application/json'}
          url: "/entities/#{id}"
          params: {include: 'all'}
        )

      relation_load: (entity_id, relation_name, page) ->
        page ||= 1
        
        http(
          method: 'get'
          url: "/entities/#{entity_id}/relationships.json"
          params: {page: page, relation_name: relation_name}
        )

      media_relation_load: (entity_id, relation_name, page) ->
        http(
          method: 'get'
          url: "/entities/#{entity_id}/relationships.json"
          params: {page: page, relation_name: relation_name, kind_id: 1}
        )

      deep_media_load: (entity_id, page = 1) ->
        http(
          method: 'get'
          url: "/entities/#{entity_id}/relationships.json"
          params: {page: page, per_page: 9, kind_id: 1}
        )
    }
]