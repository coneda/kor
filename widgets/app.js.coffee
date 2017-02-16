Zepto.extend Zepto.ajaxSettings, {
  dataType: 'json'
  contentType: 'application/json'
  complete: (xhr) -> console.log(xhr.responseURL, JSON.parse(xhr.response))
}

window.wApp = {
  bus: riot.observable()
  data: {}
  mixins: {}
  setup: ->
    wApp.routing.setup()
    wApp.i18n.setup()
}
