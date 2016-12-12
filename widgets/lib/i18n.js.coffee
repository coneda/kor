wApp.i18n = {
  translate: (input, options = {}) ->
    try
      options.count ||= 1
      parts = input.split(".")
      result = wApp.data.translations[wApp.data.locale]
      
      for part in parts
        result = result[part]
      
      count = if options.count == 1 then 'one' else 'other'
      result = result[count] || result
      
      for key, value of options.interpolations
        regex = new RegExp("%\{#{key}\}", "g")
        tvalue = wApp.i18n.translate(value)
        value = tvalue if tvalue && (tvalue != value)
        result = result.replace regex, value
      
      if options.capitalize
        result = wApp.utils.capitalize(result)

      result
    catch error
      # console.log error
      ""
}

wApp.i18n.t = wApp.i18n.translate
