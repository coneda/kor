kor.controller "gallery_controller", [
  "$scope", "$routeParams", "entities_service", "kor_tools", "paths_service",
  (scope, rp, es, kt, ps) ->
    query = ->
      es.gallery(page: rp.page).success (data) ->
        scope.result = data
        scope.result.grouped_records = kt.in_groups_of(data.records)

        ids = []
        for entity in data.records
          ids.push(entity.id)

        ps.gallery(ids).success (data) ->
          scope.result.graph = {}
          for path in data
            scope.result.graph[path[0]['id']] = path

    scope.$on "$routeChangeSuccess", query
    scope.$on "$routeUpdate", query
]