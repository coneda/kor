kor.service "relationships_service", [
  "$http",
  (http) ->
    service = {
      show: (id) ->
        request = {
          method: "get"
          url: "/directed_relationships/#{id}.json"
        }
        http(request)

      create: (relationship) ->
        request = {
          method: "post"
          url: "/relationships.json"
          data: {
            relationship: relationship
          }
        }
        http(request)

      update: (id, relationship) ->
        request = {
          method: "patch"
          url: "/relationships/#{id}.json"
          data: {
            relationship: relationship
          }
        }
        http(request)

      destroy: (id) ->
        request = {
          method: 'delete'
          url: "/relationships/#{id}.json"
        }
        http(request)
    }
]