kor.directive "korRelation", ["entities_service", 'templates_service',
  (es, ts) ->
    directive = {
      template: -> ts.get('relation')
      scope: {
        entity: "=korEntity"
        relation_name: "=korRelation"
        count: "=korCount"
      }
      replace: true
      link: (scope, element, attrs) ->
        scope.visible = false
        scope.page = 1

        scope.switch = (event) ->
          event.preventDefault()
          scope.visible = !scope.visible

        fetch = ->
          es.relation_load(scope.entity.id, scope.relation_name, scope.page).success (data) ->
            # console.log data
            scope.relationships = data.records

        scope.$watchGroup ["page", "count"], fetch
        scope.$on 'relationship-saved', fetch

    }
]
