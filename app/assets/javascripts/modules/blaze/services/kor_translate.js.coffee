kor.service('korTranslate', ["korData", (korData) ->
  return {
    translate: (input, options = {}) ->
      try
        options.count ||= 1
        parts = input.split(".")
        result = korData.info.translations[korData.info.locale]
        
        for part in parts
          result = result[part]
        
        count = if options.count == 1 then 'one' else 'other'
        result = result[count] || result
        
        for key, value of options.interpolations
          regex = new RegExp("%\{#{key}\}", "g")
          value = tvalue if (tvalue = this.translate(value)) != value
          result = result.replace regex, tvalue
          
        result
      catch error
        ""
  }
])