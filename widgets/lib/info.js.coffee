wApp.info = {
  setup: ->
    Zepto.ajax(
      url: '/info'
      success: (data) -> wApp.info.meta = data
    )
}
