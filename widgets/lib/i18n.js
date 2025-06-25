 wApp.i18n = {
  setup: function() {
    Zepto.ajax({
      url: '/translations',
      success: (data) => wApp.i18n.translations = data.translations
    })
  },
  locales: function() {
    if (!wApp.i18n.translations){
      return []
    }
    return Object.keys(wApp.i18n.translations)
  },
  translate: function(locale, input, options) {
    if (!options){
      options = {}
    }
    if (!wApp.i18n.translations) {
      return ""
    }

  try {
    if (typeof options.count === undefined) {
      options.count = 1
    }
    if (options.warnMissingKey === undefined) {
      options.warnMissingKey = true
    }
    var parts = input.split(".")
    var result = wApp.i18n.translations[locale]
    var part
    for (var i = 0; i < parts.length; i++) {
      part = parts[i]
      result = result[part]
    }
    var count = options.count === 1 ? 'one' : 'other'
    result = result[count] || result
      if (options.interpolations) {
        for (var key in options.interpolations) {
          if (options.interpolations.hasOwnProperty(key)) {
            var value = options.interpolations[key]
            var regex = new RegExp("%\\{" + key + "\\}", "g")
            var tvalue = wApp.i18n.translate(locale, value, { warnMissingKey: false })
            if (tvalue && tvalue !== value) {
              value = tvalue
            }
            result = result.replace(regex, value)
          }
        }
      }
      if (options.capitalize) {
        result = wApp.utils.capitalize(result)
      }

      return result
  }
    catch (error) {
      if (options.warnMissingKey) {
        console.warn(error, 'for key', input)
      }
      return ""
    }
  },
  localize: function(locale, input, format_name = 'date.formats.default') {
    try {
      if (!input) {
        return ""
      }
      var format = wApp.i18n.translate(locale, format_name)
      var date = new Date(input)
      return strftime(format, date)
    } catch (error) {
      console.warn(error, 'for key', input)
      return ""
    }
  },
  humanSize: function(input) {
    if (input < 1024) {
      return input + " B"
    }
    if (input < 1024 * 1024) {
      return (Math.round(input / 1024 * 100) / 100) + " KB"
    }
    if (input < 1024 * 1024 * 1024) {
      return (Math.round(input / (1024 * 1024) * 100) / 100) + " MB"
    }
    if (input < 1024 * 1024 * 1024 * 1024) {
      return (Math.round(input / (1024 * 1024 * 1024) * 100) / 100) + " GB"
    }
    return ""
  }
}
wApp.mixins.i18n = {
  t: function(input, options = {}) {
    return wApp.i18n.translate(this.locale(), input, options)
  },
  tcap: function(input, options = {}) {
    options['capitalize'] = true
    return wApp.i18n.translate(this.locale(), input, options)
  },
  l: function(input, format_name) {
    return wApp.i18n.localize(this.locale(), input, format_name)
  },
  hs: function(input) {
    return wApp.i18n.humanSize(input)
  }
}
wApp.i18n.t = wApp.i18n.translate
