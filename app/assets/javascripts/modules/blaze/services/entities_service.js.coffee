kor.service "entities_service", [
  "$http",
  (http) ->
    service = {
      show: (id) ->
        http(
          method: 'get'
          url: "/api/1.0/entities/#{id}"
        )

      relation_load: (id, relation, page = 1) ->
        page = Math.min(relation.total_pages, page)
        page = Math.max(1, page)
        
        http(
          method: 'get',
          url: "/api/1.0/entities/#{id}/relationships",
          params: {'page': page - 1, name: relation.name}
        )

      media_relation_load: (id, relation, page = 1) ->
        page = Math.min(relation.total_pages, page)
        page = Math.max(1, page)

        http(
          method: 'get',
          url: "/api/1.0/entities/#{id}/relationships",
          params: {'page': page - 1, name: relation.name, media: true}
        )

      deep_media_load: (relationship, page = 1) ->
        page = Math.min(relationship.total_media_pages, page)
        page = Math.max(1, page)

        http(
          method: 'get'
          url: "/api/1.0/entities/#{relationship.entity.id}/relationships"
          params: {'page': page - 1, media: true, limit: 12}
        )
    }
]