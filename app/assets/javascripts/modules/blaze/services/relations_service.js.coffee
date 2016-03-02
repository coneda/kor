kor.service "relations_service", [
  "$http",
  (http) ->
    service = {
      names: (from_kind_ids = null, to_kind_ids = null) ->
        http(
          method: "get"
          params: {
            "from_kind_ids": from_kind_ids
            "to_kind_ids": to_kind_ids
          }
          url: "/relations/names.json"
        )
    }
]