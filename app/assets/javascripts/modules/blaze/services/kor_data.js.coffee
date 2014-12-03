kor.service('korData', [
  '$rootScope', '$location', '$http', 
  (rs, location, http) ->
    service = {
      entity: null
      session: null

      error: -> if service.info then service.info.session.flash.error else null
      notice: -> if service.info then service.info.session.flash.notice else null

      logged_in: ->
        try
          service.info.session.user.name == 'guest'
        catch e
          false
      
      session_load: ->
        http(method: 'get', url: "/api/1.0/info", type: "json").success (data) ->
          service.info = data
          rs.$broadcast "kor-session-load-complete", data
        
      toggle_session_panel: (state) ->
        state = if state then 'show' else 'hide'
        http(method: 'get', url: "/tools/session_info", params: {show: state})

      fully_loaded: false

    }
])