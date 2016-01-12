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
          headers: {accept: 'application/json'}
          url: "/entities/isolated"
          params: params
        )

      show: (id) ->
        http(
          method: 'get'
          headers: {accept: 'application/json'}
          url: "/entities/#{id}"
        )

      relation_load: (entity_id, relation) ->
        relation.page ||= 1
        
        http(
          method: 'get',
          url: "/api/1.0/entities/#{entity_id}/relationships",
          params: {page: relation.page - 1, name: relation.name}
        )

      media_relation_load: (id, relation) ->
        http(
          method: 'get',
          url: "/api/1.0/entities/#{id}/relationships",
          params: {'page': relation.page - 1, name: relation.name, media: true}
        )

      deep_media_load: (relationship, page = 1) ->
        http(
          method: 'get'
          url: "/api/1.0/entities/#{relationship.entity.id}/relationships"
          params: {'page': page - 1, media: true, limit: 9}
        )
    }
]