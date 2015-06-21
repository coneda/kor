kor.controller('root_controller', ['$scope', 'korData', 'korFlash', (scope, kd, korFlash) ->
  scope.$on 'kor-session-load-complete', -> scope.info = kd.info
    
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

  scope.is_guest = ->
    return false unless scope.info

    if user = scope.info.session.user
      user.name == 'guest'
    else
      false

  window.s = scope

  kd.session_load()
  
])