kor.directive "korToClipboard", [
  "templates_service", "session_service",
  (ts, ss) ->
    directive = {
      template: ts.get("to-clipboard")
      replace: true
      scope: {
        entity: "=korToClipboard"
      }
      link: (scope, element) ->
        scope.in_clipboard = -> ss.in_clipboard(scope.entity)
        scope.allowed_to_any = ss.allowed_to_any
        scope.is_guest = ss.is_guest

        $(element).on "click", (event) ->
          event.preventDefault()
          if scope.in_clipboard()
            ss.from_clipboard(scope.entity)
          else
            ss.to_clipboard(scope.entity)
    }
]