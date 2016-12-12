Zepto.extend Zepto.ajaxSettings, {
  type: 'GET'
  dataType: 'json'
  contentType: 'application/json'
  accept: 'application/json'
}

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
