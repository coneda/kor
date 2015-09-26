kor.controller "entities_controller", [
  "$scope", "$routeParams", "entities_service", "kor_tools", "$location",
  (scope, rp, es, kt, l) ->
    query = ->
      es.isolated(page: rp.page).success (data) ->
        scope.result = data
        scope.result.grouped_records = kt.in_groups_of(data.records)


    scope.$watch "result.page", -> 
      if scope.result
        l.search("page", scope.result.page)
    scope.$on "$routeChangeSuccess", query
    scope.$on "$routeUpdate", query
]