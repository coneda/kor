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

        template = c(scope.generator.directive)(scope)
        element.html(template)
    }
]