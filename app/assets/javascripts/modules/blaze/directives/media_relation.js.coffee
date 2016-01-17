kor.directive "korMediaRelation", ["entities_service", "session_service",
  (es, ss) ->
    directive = {
      templateUrl: "/tpl/media_relation"
      scope: {
        entity: "=korEntity"
        relation: "=korMediaRelation"
      }
      replace: true
      link: (scope, element, attrs) ->
        scope.allowed_to = (policy) -> ss.allowed_to(policy, scope.entity)
        scope.allowed_to_any = ss.allowed_to_any

        scope.$watch "relation.page", ->
          es.media_relation_load(scope.entity.id, scope.relation).success (data) ->
            scope.relation.relationships = data.relationships
    }
]