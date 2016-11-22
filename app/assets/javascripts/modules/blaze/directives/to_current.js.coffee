kor.directive "korToCurrent", [
  "session_service",
  (ss) ->
    directive = {
      link: (scope, element) ->
        scope.$watch 'entity', (n, o) ->
          if n && scope.clickPending
            scope.clickPending = false
            click()

        click = (event) ->
          event.preventDefault() if event
          if scope.entity
            ss.to_current(scope.entity)
          else
            scope.clickPending = true

        $(element).on "click", click
    }
]