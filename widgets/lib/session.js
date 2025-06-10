wApp.session = {
  setup: function () {
    var reload = function () {
      return Zepto.ajax({
        method: 'get',
        url: '/session',
        success: function (data) {
          wApp.session.current = data.session
          riot.update()
        }
      })
    }

    wApp.bus.on('reload-session', reload)

    return reload()
  },

  csrfToken: function () {
    return (wApp.session.current || {}).csrfToken
  }
}

wApp.mixins.sessionAware = {
  session: function () {
    return wApp.session.current
  },
  currentUser: function () {
    return this.session().user
  },
  locale: function () {
    return this.session().locale
  },
  isGuest: function () {
    return this.currentUser() && this.currentUser().name === 'guest'
  },
  isLoggedIn: function () {
    return this.currentUser() && !this.isGuest()
  }
}
