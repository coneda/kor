const config = {
  setup: function () {
    return Zepto.ajax({
      url: '/settings',
      success: function (data) {
        wApp.config.data = data
      }
    })
  },
  refresh: function () {
    wApp.config.setup().then(function () {
      riot.update()
    })
  },
  hasHelp: function (key) {
    return wApp.config.helpFor(key).length > 0
  },
  helpFor: function (key) {
    var locale = wApp.session.current.locale
    var help = wApp.config.data.values['help_' + key + '.' + locale]
    return help ? help.trim() : ""
  },
  showHelp: function (k) {
    wApp.bus.trigger('modal', 'kor-help', {key: k})
  },
  env: {
    ROOT_URL: process.env.ROOT_URL
  }
}

if (typeof wApp !== 'undefined') {
  wApp.config = config

  wApp.mixins.config = {
    config: function () {
      return wApp.config.data.values
    }
  }

  wApp.bus.on('config-updated', wApp.config.refresh)
}

export default config

