wApp.session = {
  setup: ->
    $.ajax(
      method: 'get',
      url: '/session'
      success: (data) -> wApp.session.current = data
    )
}

wApp.mixins.sessionAware = {
  session: -> wApp.session.current
  currentUser: -> this.session().user
  locale: -> this.session().locale
  isGuest: -> this.currentUser() && this.currentUser().name == 'guest'
  isLoggedIn: -> this.currentUser() && !this.isGuest()
}
