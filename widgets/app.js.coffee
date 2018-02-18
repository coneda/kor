# TODO: remove this
Kor = {
  loading: false
  ajax_loading: ->
    # console.warn("KOR module used")
    Kor.loading = true
  ajax_not_loading: ->
    # console.warn("KOR module used")
    Kor.loading = false
}

Zepto.extend Zepto.ajaxSettings, {
  type: 'GET'
  dataType: 'json'
  contentType: 'application/json'
  accept: 'application/json'
  beforeSend: (xhr, settings) ->
    # why are we doing this?
    unless settings.url.match(/^http/)
      settings.url = "#{wApp.baseUrl}#{settings.url}"

    Kor.ajax_loading()

    xhr.then ->
      console.log('ajax log', xhr.requestUrl, JSON.parse(xhr.response))

    xhr.requestUrl = settings.url
    # token = Zepto('meta[name=csrf-token]').attr('content')
    if wApp.session
      xhr.setRequestHeader 'X-CSRF-Token', wApp.session.csrfToken()

  complete: (xhr) -> Kor.ajax_not_loading()
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

Zepto.ajax(
  url: "/api/1.0/info"
  success: (data) ->
    window.wApp.data = data
    wApp.bus.trigger 'auth-data'
    riot.update()
)
