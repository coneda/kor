kor.directive "korEntitySelector", [
  "entities_service", "session_service", "kor_tools",
  (es, ss, kt) ->
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
              scope.group()

        scope.$watch "tab", -> 
          scope.terms = null
          scope.results = {}
          scope.entity = null
          scope.grouped_records = []

          if scope.tab == 'current'
            console.log scope.current()
            scope.results = {
              raw_records: [scope.current()]
            }
            scope.group()

          if scope.tab == 'created'
            es.recently_created().success (data) ->
              console.log data
              scope.results = {
                raw_records: data.records
              }
              scope.group()

          if scope.tab == 'visited'
            es.recently_visited().success (data) ->
              console.log data
              scope.results = {
                raw_records: data.records
              }
              scope.group()

        scope.group = -> 
          scope.grouped_records = kt.in_groups_of(
            scope.results.raw_records, 4, true
          )

        scope.$watch "terms", search

        scope.current = -> ss.get_current()

        scope.select = (entity, event) ->
          event.preventDefault()
          scope.entity = entity
    }
]