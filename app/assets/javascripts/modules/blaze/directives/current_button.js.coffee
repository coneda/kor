kor.directive "korCurrentButton", [
  "templates_service", "session_service",
  (ts, ss) ->
    directive = {
      template: ts.get("current-button")
      replace: true
      scope: {
        entity: "=korCurrentButton"
      }
      link: (scope, element) ->
        scope.is_current = -> ss.is_current(scope.entity)
        scope.allowed_to_any = ss.allowed_to_any
        scope.is_guest = ss.is_guest
    }
]