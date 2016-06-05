kor.directive "korEntityWidget", [
  "kinds_service", 'templates_service',
  (ks, ts) ->
    kinds = {}
    ks.index().success (data) ->
      for kind in data
        kinds[kind.id] = kind

    directive = {
      scope: {
        entity: "=korEntityWidget"
      }
      template: -> ts.get('entity-widget')
      link: (scope, element) ->
        scope.name = ->
          if scope.entity && scope.entity.name
            if scope.entity.distinct_name
              "#{scope.entity.name} (#{scope.entity.distinct_name})"
            else
              scope.entity.name
        scope.kind_name = -> 
          try 
            kinds[scope.entity.kind_id].name
          catch e

    }

    directive
]