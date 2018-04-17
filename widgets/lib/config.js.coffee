wApp.config = {
  setup: ->
    Zepto.ajax(
      url: '/settings'
      success: (data) -> wApp.config.data = data
    )
}

wApp.mixins.config = {
  config: -> wApp.config.data.values
}
