kor.directive "korRelationshipEditor", [
  "relationships_service", "korData",
  (rs, kd) ->
    directive = {
      scope: {
        source: "=korSourceEntity"
        relation_name: "=korRelationName"
        close: "&korClose"
      }
      templateUrl: "/tpl/relationships/form"
      link: (scope, element) ->
        scope.errors = null
        scope.properties = []

        scope.cancel = ->
          scope.close refresh: false

        scope.save = ->
          relationship = {
            from_id: (scope.source || {}).id
            relation_name: scope.relation_name
            to_id: (scope.target || {}).id
            properties: (prop.value for prop in scope.properties)
          }

          # console.log relationship

          promise = rs.create(relationship)
          promise.success (data) -> 
            scope.errors = null
            kd.set_notice(data.message)
            # console.log scope
            scope.close(refresh: true)
          promise.error (data) -> 
            scope.errors = data
            # console.log(data)

        scope.add_property = (event) ->
          event.preventDefault()
          scope.properties.push {value: scope.new_property}
          scope.new_property = ""

    }
]
