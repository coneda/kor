kor.service('korTranslate', ["korData", (korData) ->
  service = {
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
    localize: (input, format_name = 'default') ->
      try
        format = service.translate "date.formats.#{format_name}"
        result = new FormattedDate(input)
        result.strftime format
      catch error
        ""
  }
])