wApp.session = {
  setup: function () {
    const reload = function () {
      return Zepto.ajax({
        method: 'get',
        url: '/session',
        success: function (data) {
          wApp.session.current = data.session
          console.log('SESSION loaded')
        }
      })
    }

    wApp.bus.on('reload-session', () => {
      reload().then(data => riot.update())
    })

    wApp.bus.on('request-complete', response => {
      if (response.status == 401 || response.status == 403) {
        reload().then(data => riot.update())
      }
    })

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
  },
  isStatic: function() {
    return wApp.info.data.static
  }
}
