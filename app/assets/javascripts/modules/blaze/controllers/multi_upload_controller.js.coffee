kor.controller "multi_upload_controller", [
  "$scope", "korData",
  (scope, kd) ->
    kd.fully_loaded = true
    window.s = scope
    window.kd = kd
]