Zepto.extend Zepto.ajaxSettings, {
  dataType: 'json'
  contentType: 'application/json'
  accept: 'application/json'
  beforeSend: (xhr, settings) ->
    xhr.always ->
      console.log('ajax log', xhr.requestUrl, JSON.parse(xhr.response))

    xhr.requestUrl = settings.url
    if wApp.session.current
      xhr.setRequestHeader 'X-CSRF-Token', wApp.session.csrfToken()
}

window.wApp = {
  bus: riot.observable()
  data: {}
  mixins: {}
  state: {}
  setup: ->
    return [
      wApp.config.setup()
      wApp.session.setup(),
      wApp.i18n.setup(),
      wApp.info.setup(),
    ]
}
