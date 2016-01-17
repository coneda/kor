kor.directive "korRelationshipEditor", [
  "relationships_service", "korData",
  (rs, kd) ->
    directive = {
      scope: {
        source: "=korSourceEntity"
        relation_name: "=korRelationName"
      }
      templateUrl: "/tpl/relationships/form"
      link: (scope, element) ->
        scope.errors = {}
        scope.save = ->
          console.log scope
          relationship = {
            from_id: (scope.source || {}).id
            relation_name: scope.relation_name
            to_id: (scope.target || {}).id
          }

          console.log relationship

          promise = rs.create(relationship)
          promise.success (data) -> 
            scope.errors = {}
            kd.set_notice(data.message)
          promise.error (data) -> 
            scope.errors = data
            console.log(data)

    }
]
