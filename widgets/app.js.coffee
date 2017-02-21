Zepto.extend Zepto.ajaxSettings, {
  dataType: 'json'
  contentType: 'application/json'
  accept: 'application/json'
  complete: (xhr) -> console.log(xhr.responseURL, JSON.parse(xhr.response))
  beforeSend: (xhr, settings) ->
    if wApp.session.current
      xhr.setRequestHeader 'X-CSRF-Token', wApp.session.csrfToken()
}

window.wApp = {
  bus: riot.observable()
  data: {}
  mixins: {}
  setup: ->
    wApp.routing.setup()
    wApp.i18n.setup()
}
