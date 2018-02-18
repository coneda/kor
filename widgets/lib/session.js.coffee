wApp.session = {
  setup: ->
    Zepto.ajax(
      method: 'get',
      url: '/session'
      success: (data) -> wApp.session.current = data.session
    )
  csrfToken: -> wApp.session.current.csrfToken
  data: -> wApp.data
}

wApp.mixins.sessionAware = {
  session: -> wApp.session.current
  currentUser: -> this.session().user
  locale: -> this.session().locale
  isGuest: -> this.currentUser() && this.currentUser().name == 'guest'
  isLoggedIn: -> this.currentUser() && !this.isGuest()
}

# previous session handling:
# wApp.mixins.session = {
#   init: -> 
#     tag = this
#     redirectDenied = ->
#       redirect = false
#       for rr in tag.requireRoles
#         if user = wApp.data.session.user
#           if !user.auth.roles[rr]
#             redirect = true
#         else
#           redirect = true

#       if redirect
#         window.location.hash = '#/denied'

#     if wApp.data && wApp.data.session
#       redirectDenied()
#     else
#       wApp.bus.one 'auth-data', ->
#         redirectDenied()
# }
