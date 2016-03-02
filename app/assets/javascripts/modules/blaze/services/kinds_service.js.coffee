kor.service "kinds_service", [
  "$http",
  (http) ->
    service = {
      index: ->
        http(
          method: "get"
          url: "/kinds.json"
        )
    }
]