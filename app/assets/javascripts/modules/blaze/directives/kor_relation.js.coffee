kor.directive "korRelation", ["entities_service",
  (es) ->
    directive = {
      templateUrl: "/tpl/relation"
      scope: {
        entity: "=korEntity"
        relation: "=korRelation"
      }
      replace: true
      link: (scope, element, attrs) ->
        scope.visible = false

        scope.switch = (event) ->
          event.preventDefault()
          scope.visible = !scope.visible

        scope.$watch "relation.page", ->
          es.relation_load(scope.entity.id, scope.relation).success (data) ->
            scope.relation.relationships = data.relationships
    }
]