wApp.i18n = {
  setup: ->
    $.ajax(
      url: '/translations'
      success: (data) -> wApp.i18n.translations = data
    )
  translate: (locale, input, options = {}) ->
    return "" unless wApp.i18n.translations

    try
      options.count ||= 1
      parts = input.split(".")
      result = wApp.i18n.translations[locale]
      
      for part in parts
        result = result[part]
      
      count = if options.count == 1 then 'one' else 'other'
      result = result[count] || result
      
      for key, value of options.interpolations
        regex = new RegExp("%\{#{key}\}", "g")
        tvalue = wApp.i18n.translate(locale, value)
        value = tvalue if tvalue && (tvalue != value)
        result = result.replace regex, value

      if options['capitalize']
        result = result.charAt(0).toUpperCase() + result.slice(1)
        
      result
    catch error
      console.log arguments
      console.log error
      "d"
  localize: (locale, input, format_name = 'default') ->
    try
      format = wApp.i18n.translate locale, "date.formats.#{format_name}"
      result = new Strftime(input)
      result.render format
    catch error
      ""
}

wApp.mixins.i18n = {
  t: (input, options = {}) ->
    wApp.i18n.translate this.locale(), input, options
  tcap: (input, options = {}) ->
    options['capitalize'] = true
    wApp.i18n.translate this.locale(), input, options
  l: (input, format_name) ->
    wApp.i18n.localize this.locale(), input, format_name

}