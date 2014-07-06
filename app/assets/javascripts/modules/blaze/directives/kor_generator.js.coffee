kor.directive "korGenerator", [
  "$http", "$compile"
  (http, c) ->
    directive = {
      scope: {
        entity: "=korEntity"
        generator: "=korGenerator"
      }
      link: (scope, element, attrs) ->
        url = "/kinds/#{scope.entity.kind_id}/generators/#{scope.generator.id}"
        http(method: "get", url: url).success (data) ->
          template = c(data)(scope)
          element.html(template)
    }
]