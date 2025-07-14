Zepto.extend (Zepto.ajaxSettings, {
  type: 'GET',
  dataType: 'json',
  contentType: 'application/json',

  beforeSend: function (xhr, settings) {
    wApp.state.requests.push(xhr)
    wApp.bus.trigger('ajax-state-changed')


    xhr.then(function (data) {
      console.log('ajax ' + settings.type + ': ', xhr.requestUrl, data || JSON.parse(xhr.response))
    })

    xhr.always(function () {
      wApp.state.requests.pop()
      wApp.bus.trigger('ajax-state-changed')
    })

    xhr.fail(function (xhr) {
      if (xhr.status === 401) {
        wApp.bus.trigger('reload-session')
      }
    })

    xhr.requestUrl = settings.url
    if (settings.type.match(/POST|PATCH|PUT|DELETE/i) && wApp.session) {
      xhr.setRequestHeader('X-CSRF-Token', wApp.session.csrfToken())
    }
  }
})

window.wApp = {
  bus: riot.observable(),
  mixins: {},
  state: {
    requests: []
  },
  setup: function () {
    // these require no ajax requests during setup
    wApp.clipboard.setup()
    wApp.entityHistory.setup()

    return Promise.all([
      wApp.session.setup(),
      wApp.config.setup(),
      wApp.i18n.setup(),
      wApp.info.setup()
    ])
  }
}

