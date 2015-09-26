kor.directive "korSimpleEntity", [
  "templates_service",
  (ts) ->
    directive = {
      template: ts.get("entity")
      replace: true
      scope: {
        entity: "=korSimpleEntity"
      }
    }
]