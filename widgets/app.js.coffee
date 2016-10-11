$.extend $.ajaxSettings, {
  type: 'get'
  dataType: 'json'
  contentType: 'application/json'
}

window.wApp = {
  bus: riot.observable()
  data: {}
  mixins: {}
}

wApp.bus.on 'angular-data-ready', (service) ->
  wApp.data.session = service.info.session
  wApp.data.session.locale = service.info.locale
  wApp.data.translations = service.info.translations
  wApp.data.medium_kind_uuid = service.info.medium_kind_uuid
  riot.update()
