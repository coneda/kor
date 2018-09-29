wApp.config = {
  setup: ->
    Zepto.ajax(
      url: '/settings'
      success: (data) -> wApp.config.data = data
    )
  hasHelp: (key) ->
    wApp.config.helpFor(key).length > 0
  helpFor: (key) ->
    help = wApp.config.data.values['help_' + key]
    if help then help.trim() else ""
  showHelp: (k) -> wApp.bus.trigger('modal', 'kor-help', {key: k});
}

wApp.mixins.config = {
  config: -> wApp.config.data.values
}

wApp.bus.on('config-updated', wApp.config.setup)
