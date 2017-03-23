Zepto.extend Zepto.ajaxSettings, {
  dataType: 'json'
  contentType: 'application/json'
  accept: 'application/json'
  beforeSend: (xhr, settings) ->
    unless settings.url.match(/^http/)
      settings.url = "#{wApp.baseUrl}#{settings.url}"

    xhr.then ->
      console.log("ajax #{settings.type}", xhr.requestUrl, JSON.parse(xhr.response))

    xhr.requestUrl = settings.url
    if wApp.session.current
      xhr.setRequestHeader 'X-CSRF-Token', wApp.session.csrfToken()
}

window.wApp = {
  bus: riot.observable()
  data: {}
  mixins: {}
  state: {}
  baseUrl: $('script[kor-url]').attr('kor-url') || ''
  setup: ->
    wApp.clipboard.setup()

    return [
      wApp.config.setup()
      wApp.session.setup(),
      wApp.i18n.setup(),
      wApp.info.setup(),
    ]
}

