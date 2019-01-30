kor.controller('root_controller', [
  '$scope', 'korData', "session_service", "$location",
  (scope, kd, ss, l) ->
    scope.$on 'kor-session-load-complete', -> scope.info = kd.info

    scope.previous_current_entities = ->
      if scope.history_available()
        scope.info.session.current_history.slice(0, -1)
      else
        []

    scope.current_entity = ->
      if scope.history_available()
        arr = scope.info.session.current_history
        arr[arr.length - 1]
      else
        null
      
    scope.history_available = ->
      if scope.info
        scope.info.session.current_history.length > 0
      else
        false
    
    scope.toggle_session_panel = ->
      scope.info.session.show_panel = !scope.info.session.show_panel
      kd.toggle_session_panel scope.info.session.show_panel
      
    scope.fully_loaded = -> kd.fully_loaded

    scope.flash_error = -> kd.error()
    scope.flash_notice = -> kd.notice()

    scope.is_guest = ss.is_guest

    scope.login_url = ->
      result = "/login"
      if rt = l.search()['return_to']
        "#{result}?return_to=#{rt}"
      else
        result

    scope.back = (event) ->
      event.preventDefault()
      window.history.back()

    kd.session_load()
])
