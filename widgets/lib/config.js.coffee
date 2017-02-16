wApp.config = {
  setup: ->
    Zepto.ajax(
      url: '/config'
      success: (data) -> wApp.config.data = data
    )
}

wApp.mixins.config = {
  config: -> wApp.config.data
}
