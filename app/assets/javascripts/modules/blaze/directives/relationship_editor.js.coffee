kor.directive "korRelationshipEditor", [
  "relationships_service", "korData",
  (rs, kd) ->
    directive = {
      scope: {
        source: "=korSourceEntity"
        relation_name: "=korRelationName"
        update: "=korUpdate"
      }
      templateUrl: "/tpl/relationships/form"
      link: (scope, element) ->
        scope.errors = {}
        scope.properties = []
        scope.save = ->
          relationship = {
            from_id: (scope.source || {}).id
            relation_name: scope.relation_name
            to_id: (scope.target || {}).id
            properties: scope.properties
          }

          console.log relationship

          promise = rs.create(relationship)
          promise.success (data) -> 
            scope.errors = {}
            kd.set_notice(data.message)
            console.log scope
            scope.update()
          promise.error (data) -> 
            scope.errors = data
            console.log(data)

    }
]
