kor.controller "entities_controller", [
  "$scope", "$routeParams", "entities_service",
  (scope, rp, es) ->
    query = ->
      es.isolated(page: rp.page).success (data) -> scope.result = data

    scope.$on "$routeChangeSuccess", query
    scope.$on "$routeUpdate", query
]