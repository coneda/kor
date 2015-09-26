kor.directive "korToCurrent", [
  "session_service",
  (ss) ->
    directive = {
      link: (scope, element) ->
        $(element).on "click", (event) ->
          event.preventDefault()
          ss.to_current(scope.entity)
    }
]