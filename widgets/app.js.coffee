Zepto.extend Zepto.ajaxSettings, {
  type: 'GET'
  dataType: 'json'
  contentType: 'application/json'
  beforeSend: (xhr, settings) ->
    wApp.state.requests.push xhr
    wApp.bus.trigger 'ajax-state-changed'

    xhr.then ->
      console.log('ajax ' + settings.type + ': ', xhr.requestUrl, JSON.parse(xhr.response))

    xhr.always ->
      wApp.state.requests.pop()
      wApp.bus.trigger 'ajax-state-changed'

    xhr.fail (xhr) ->
      if xhr.status == 401
        wApp.bus.trigger('reload-session')

    xhr.requestUrl = settings.url
    if settings.type.match(/POST|PATCH|PUT|DELETE/i) && wApp.session
      xhr.setRequestHeader 'X-CSRF-Token', wApp.session.csrfToken()
}

$.tinyAutocomplete.prototype.beforeReceiveData = (data, xhr) ->
  this.json = data.records;
  this.field.trigger('receivedata', [this, data, xhr]);
  this.onReceiveData(this.json);

window.wApp = {
  bus: riot.observable()
  mixins: {}
  state: {
    requests: []
  }
  setup: ->
    wApp.clipboard.setup()
    wApp.entityHistory.setup()

    return [
      wApp.config.setup()
      wApp.session.setup(),
      wApp.i18n.setup(),
      wApp.info.setup(),
    ]
}
