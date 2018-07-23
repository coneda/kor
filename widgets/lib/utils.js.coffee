wApp.utils = {
  shorten: (str, n = 15) ->
    if str && str.length > n
      str.substr(0, n - 1) + '&hellip;'
    else
      str
  inGroupsOf: (per_row, array, dummy = null) ->
    result = []
    current = []
    for i in array
      if current.length == per_row
        result.push(current)
        current = []
      current.push(i)
    if current.length > 0
      if dummy
        while current.length < per_row
          current.push(dummy)
      result.push(current)
    result
  toInteger: (value) ->
    if Zepto.isNumeric(value)
      parseInt(value)
    else
      value
  toArray: (value) -> 
    if value == null || value == undefined
      []
    else
      if Zepto.isArray(value) then value else [value]
  uniq: (a) ->
    output = {}
    output[a[key]] = a[key] for key in [0...a.length]
    value for key, value of output
  scrollToTop: ->
    if document.body.scrollTop != 0 || document.documentElement.scrollTop != 0
      window.scrollBy 0, -50
      wApp.state.scrollToTopTimeOut = setTimeout('wApp.utils.scrollToTop()', 10)
    else
      clearTimeout wApp.state.scrollToTopTimeOut
  capitalize: (value) ->
    value.charAt(0).toUpperCase() + value.slice(1)

  confirm: (string) -> 
    string ||= wApp.i18n.t(wApp.session.current.locale, 'confirm.sure')
    window.confirm(string)

  toIdArray: (obj) ->
    return [] unless obj
    obj = obj.split(',') unless Zepto.isArray(obj)
    parseInt(o) for o in obj
}
