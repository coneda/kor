kor.directive "korEntityWidget", [
  "kinds_service",
  (ks) ->
    kinds = {}
    ks.index().success (data) ->
      for kind in data
        kinds[kind.id] = kind

    directive = {
      scope: {
        entity: "=korEntityWidget"
      }
      templateUrl: "/tpl/entities/widget"
      link: (scope, element) ->
        scope.kind_name = -> 
          try 
            kinds[scope.entity.kind_id].name
          catch e
    }

    directive
]