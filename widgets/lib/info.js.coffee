wApp.info = {
  setup: ->
    Zepto.ajax(
      url: '/info'
      success: (data) -> wApp.info.data = data.info
    )
}

wApp.mixins.info = {
  info: -> wApp.info.data
  rootUrl: -> this.info().url
}
