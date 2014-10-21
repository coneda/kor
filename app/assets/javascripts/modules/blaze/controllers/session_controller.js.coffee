kor.controller('korSessionCtrl', ['$scope', 'korData', 'korFlash', (scope, korData, korFlash) ->
  scope.$on 'kor-session-load-complete', -> scope.info = korData.info
    
  scope.history_available = ->
    if scope.info
      scope.info.session.current_history.length > 0
    else
      false
  
  scope.toggle_session_panel = ->
    scope.info.session.show_panel = !scope.info.session.show_panel
    korData.toggle_session_panel scope.info.session.show_panel
    
  scope.fully_loaded = -> korData.fully_loaded

  scope.flash_error = -> korData.error()
  scope.flash_notice = -> korData.notice()

  korData.session_load()
  
])