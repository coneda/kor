kor.directive "korGenerator", [
  "$http", "$compile", "korTranslate",
  (http, c, kt) ->
    directive = {
      scope: {
        entity: "=korEntity"
        generator: "=korGenerator"
      }
      link: (scope, element, attrs) ->
        scope.locale = -> kt.current_locale()

        url = "/kinds/#{scope.entity.kind_id}/generators/#{scope.generator.id}"
        http(method: "get", url: url).success (data) ->
          template = c(data)(scope)
          element.html(template)
    }
]