let instance = null

export default class Config {
  static setup() {
    return Zepto.ajax({
      url: '/settings',
      success: function (data) {
        instance = new Config(data)
      }
    })

    instance = new Config()
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

  static env = {
    ROOT_URL: process.env.ROOT_URL,
    RAILS_ENV: process.env.RAILS_ENV
  }

  constructor(data) {
    this.data = data
  }

  refresh() {
    wApp.config.setup().then(function () {
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
