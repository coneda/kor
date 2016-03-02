kor.directive "korMediaRelation", ["entities_service", "session_service",
  'templates_service',
  (es, ss, ts) ->
    directive = {
      template: -> ts.get('media-relation')
      scope: {
        entity: "=korEntity"
        relation_name: "=korMediaRelation"
        count: "=korCount"
      }
      replace: true
      link: (scope, element, attrs) ->
        scope.visible = false
        scope.page = 1

        scope.switch = (event) ->
          event.preventDefault()
          scope.visible = !scope.visible

        scope.$watchGroup ["page", "count"], ->
          es.media_relation_load(scope.entity.id, scope.relation_name, scope.page).success (data) ->
            # console.log data
            scope.relationships = data

        scope.allowed_to = (policy) -> ss.allowed_to(policy, scope.entity)
        scope.allowed_to_any = ss.allowed_to_any
    }
]