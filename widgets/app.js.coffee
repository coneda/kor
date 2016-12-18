Zepto.extend Zepto.ajaxSettings, {
  dataType: 'json'
  contentType: 'application/json'
}

window.wApp = {
  bus: riot.observable()
  data: {}
}
