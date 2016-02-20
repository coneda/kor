kor.controller "multi_upload_controller", [
  "$scope", "korData", "$route",
  (scope, kd, r) ->
    scope.$on 'current-changed', -> r.reload()
]