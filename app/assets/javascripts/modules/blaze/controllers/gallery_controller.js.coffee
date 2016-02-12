kor.controller "gallery_controller", [
  "$scope", "$routeParams", "entities_service", "kor_tools", "paths_service",
  (scope, rp, es, kt, ps) ->
    query = ->
      es.gallery(page: rp.page).success (data) ->
        scope.result = data
        scope.result.grouped_records = kt.in_groups_of(data.records)

    scope.$on "$routeChangeSuccess", query
    scope.$on "$routeUpdate", query
]