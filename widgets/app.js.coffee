$.extend $.ajaxSettings, {
  dataType: 'json'
  contentType: 'application/json'
}

window.wApp = {
  bus: riot.observable()
  data: {}
}

wApp.bus.on 'angular-data-ready', (service) ->
  wApp.data.session = service.info.session
  wApp.data.session.locale = service.info.locale
  wApp.data.translations = service.info.translations
  riot.update()
  