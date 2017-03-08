Zepto.extend Zepto.ajaxSettings, {
  type: 'GET'
  dataType: 'json'
  contentType: 'application/json'
  accept: 'application/json'
  beforeSend: (xhr, settings) ->
    Kor.ajax_loading()

    xhr.then ->
      console.log('ajax log', xhr.requestUrl, JSON.parse(xhr.response))

    xhr.requestUrl = settings.url
    token = Zepto('meta[name=csrf-token]').attr('content')
    xhr.setRequestHeader 'X-CSRF-Token', token

  complete: (xhr) -> Kor.ajax_not_loading()
}

$.ajaxSetup(
  dataType: "json"
  beforeSend: (xhr) -> Kor.ajax_loading()
  complete: (xhr) -> Kor.ajax_not_loading()
)

window.wApp = {
  bus: riot.observable()
  data: {}
  mixins: {}
}

Zepto.ajax(
  url: "/api/1.0/info"
  success: (data) ->
    window.wApp.data = data
    riot.update()
)
