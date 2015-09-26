kor.service "templates_service", [
  ->
    service = {
      get: (id) ->
        $("script[type='text/x-kor-tpl'][data-id='#{id}']").html()
    }
]