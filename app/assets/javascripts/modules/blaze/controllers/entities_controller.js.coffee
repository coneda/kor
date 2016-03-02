kor.controller "entities_controller", [
  "$scope", "$routeParams", "entities_service", "kor_tools",
  (scope, rp, es, kt) ->
    query = ->
      es.isolated(page: rp.page).success (data) ->
        scope.result = data
        scope.total = data.total
        scope.result.grouped_records = kt.in_groups_of(data.records)

    scope.$on "$routeChangeSuccess", query
    scope.$on "$routeUpdate", query
]