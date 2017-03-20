wApp.session = {
  data: -> wApp.data
}

wApp.mixins.session = {
  init: -> 
    tag = this
    redirectDenied = ->
      redirect = false
      for rr in tag.requireRoles
        if user = wApp.data.session.user
          if !user.auth.roles[rr]
            redirect = true
        else
          redirect = true

      if redirect
        window.location.hash = '#/denied'

    if wApp.data && wApp.data.session
      redirectDenied()
    else
      wApp.bus.one 'auth-data', ->
        redirectDenied()

}
