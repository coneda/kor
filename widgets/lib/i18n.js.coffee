wApp.i18n = {
  setup: ->
    Zepto.ajax(
      url: '/translations'
      success: (data) -> wApp.i18n.translations = data.translations
    )
  locales: -> Object.keys(wApp.i18n.translations)
  translate: (locale, input, options = {}) ->
    return "" unless wApp.i18n.translations

    try
      options.count ||= 1
      options.warnMissingKey = true if options.warnMissingKey == undefined
      parts = input.split(".")
      result = wApp.i18n.translations[locale]

      for part in parts
        result = result[part]
      
      count = if options.count == 1 then 'one' else 'other'
      result = result[count] || result
      for key, value of options.interpolations
        regex = new RegExp("%\{#{key}\}", "g")
        tvalue = wApp.i18n.translate(locale, value, warnMissingKey: false)
        value = tvalue if tvalue && (tvalue != value)
        result = result.replace regex, value
      
      if options.capitalize
        result = wApp.utils.capitalize(result)

      result
    catch error
      console.warn(error, 'for key', input) if options['warnMissingKey']
      ""
  localize: (locale, input, format_name = 'date.formats.default') ->
    try
      return "" unless input
      format = wApp.i18n.translate locale, format_name
      date = new Date(input)
      strftime(format, date)
    catch error
      console.warn error, 'for key', input
      ""
  humanSize: (input) ->
    if input < 1024
      return "#{input} B"
    if input < 1024 * 1024
      return "#{Math.round(input / 1024 * 100) / 100} KB"
    if input < 1024 * 1024 * 1024
      return "#{Math.round(input / (1024 * 1024) * 100) / 100} MB"
    if input < 1024 * 1024 * 1024 * 1024
      return "#{Math.round(input / (1024 * 1024 * 1024) * 100) / 100} GB"
}

wApp.mixins.i18n = {
  t: (input, options = {}) ->
    wApp.i18n.translate this.locale(), input, options
  tcap: (input, options = {}) ->
    options['capitalize'] = true
    wApp.i18n.translate this.locale(), input, options
  l: (input, format_name) ->
    wApp.i18n.localize this.locale(), input, format_name
  hs: (input) -> wApp.i18n.humanSize(input)
}

wApp.i18n.t = wApp.i18n.translate
