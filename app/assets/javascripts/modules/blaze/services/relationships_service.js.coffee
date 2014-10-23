kor.service "relationships_service", [
  "$http",
  (http) ->
    service = {
      show: (relationship) ->
        request = {
          method: "get"
          url: "/relationships/#{relationship.id}.json"
        }

        http(request).success (data) ->
          relationship.properties = data.properties

      update: (relationship) ->
        properties = angular.copy(relationship.properties)
        properties.push relationship.new_property

        request = {
          method: "put"
          url: "/relationships/#{relationship.id}.json"
          data: {
            relationship: {
              properties: properties
            }
          }
        }

        http(request).success (data) -> 
          relationship.properties = data.properties
          relationship.new_property = undefined
          relationship.editing = false
    }
]