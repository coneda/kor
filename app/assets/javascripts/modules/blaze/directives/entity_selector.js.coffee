kor.directive "korEntitySelector", [
  "entities_service", "session_service", "kor_tools", 'templates_service',
  (es, ss, kt, ts) ->
    directive = {
      scope: {
        entity: "=korEntitySelector"
        existing: "@korExisting"
        relation_name: "=korRelationName"
      }
      template: -> ts.get('entity-selector')
      link: (scope, element, attrs) ->
        scope.tab = "search"

        attrs.$observe 'korGridWidth', (new_value) ->
          scope.grid_width = parseInt(new_value || 3)
          scope.group()

        if scope.existing
          listener = scope.$watch 'entity', -> 
            scope.tab = 'existing' if scope.entity
            listener()

        scope.goto_tab = (tab, event) ->
          event.preventDefault() if event
          scope.tab = tab

        scope.$watch "relation_name", ->
          scope.results = {}
          scope.grouped_records = []
          scope.load_entities()

        scope.$watch "tab", ->
          scope.terms = null
          scope.results = {}
          scope.grouped_records = []
          scope.load_entities()

        scope.$watch "terms", -> scope.load_entities()

        scope.load_entities = ->
          if scope.tab == 'current'
            scope.results = {
              raw_records: [scope.current()]
            }
            scope.group()

          if scope.tab == 'created'
            params = {relation_name: scope.relation_name}
            es.recently_created(params).success (data) ->
              scope.results = {
                raw_records: data.records
              }
              scope.group()

          if scope.tab == 'visited'
            params = {relation_name: scope.relation_name}
            es.recently_visited(params).success (data) ->
              scope.results = {
                raw_records: data.records
              }
              scope.group()

          if scope.tab == 'existing'
            scope.results = {
              raw_records: [scope.entity]
            }
            scope.group()

          if scope.tab == 'search'
            if scope.terms && scope.terms.length >= 3
              params = {
                relation_name: scope.relation_name
                terms: scope.terms
                per_page: 12
              }
              es.index(params).success (data) -> 
                scope.results = data
                scope.group()


        scope.group = -> 
          if scope.results
            scope.grouped_records = kt.in_groups_of(
              scope.results.raw_records, scope.grid_width, true
            )

        scope.current = -> ss.get_current()

        scope.select = (entity, event) ->
          event.preventDefault()
          scope.entity = entity
    }
]