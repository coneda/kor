kor.service "paths_service", [
  "$http",
  (http) ->
    service = {
      gallery: (ids = []) ->
        http(
          method: 'post'
          url: '/api/1.0/paths/gallery'
          headers: {accept: 'application/json'}
          data: {id: ids}
        )
    }
]