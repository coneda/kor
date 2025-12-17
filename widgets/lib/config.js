let instance = null

export default class Config {
  static setup() {
    return Zepto.ajax({
      url: '/settings',
      success: function (data) {
        instance = new Config(data)
      }
    })
  }

  static mixins() {
    return {
      config: function () {
        return instance.data.values
      }
    }
  }

  static instance() {
    return instance
  }

  constructor(data) {
    this.data = data
  }

  refresh() {
    Config.setup().then(function () {
      wApp.config = instance
      riot.update()
    })
  }

  hasHelp(key) {
    return wApp.config.helpFor(key).length > 0
  }

  helpFor(key) {
    var locale = wApp.session.current.locale
    var help = wApp.config.data.values['help_' + key + '.' + locale]
    return help ? help.trim() : ""
  }

  showHelp(k) {
    wApp.bus.trigger('modal', 'kor-help', {key: k})
  }
}
