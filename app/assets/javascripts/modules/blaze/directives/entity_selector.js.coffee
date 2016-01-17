kor.directive "korEntitySelector", [
  "entities_service",
  (es) ->
    directive = {
      scope: {
        entity: "=korEntitySelector"
      }
      templateUrl: "/tpl/entities/selector"
      link: (scope, element, attrs) ->
        scope.tab = "search"

        search = -> 
          if scope.terms && scope.terms.length >= 3
            es.index(terms: scope.terms).success (data) -> 
              console.log(data)
              scope.results = data

        scope.$watch "tab", -> 
          scope.terms = null
          scope.results = {}
          scope.entity = null
        scope.$watch "terms", search

        scope.select = (entity) -> scope.entity = entity
    }
]