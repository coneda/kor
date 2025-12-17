wApp.auth = {
  intersect: (a, b) => {
    if (a.length > b.length) [a, b] = [b, a]

    return a.filter(v => b.indexOf(v))
  },
  login: (username, password) => {
    return Zepto.ajax({
      type: 'post',
      url: '/login',
      data: {
        username: username,
        password: password
      },
      success: (data) => wApp.bus.trigger('reload-session')
    })
  },
  logout: () => {
    return Zepto.ajax({
      type: 'delete',
      url: '/logout',
      success: (data) => {
        wApp.bus.trigger('reload-session')
        wApp.routing.path('/')
      }
    })
  }
};

class AuthMixin {
  isAdmin() {
    if (!this.currentUser()) return false

    return !!this.currentUser().admin
  }

  isAuthorityGroupAdmin() {
    if (!this.currentUser()) return false

    return !!this.currentUser().authority_group_admin
  }

  isRelationAdmin() {
    if (!this.currentUser()) return false

    return !!this.currentUser().relation_admin
  }

  isKindAdmin() {
    if (!this.currentUser()) return false

    return !!this.currentUser().kind_admin
  }

  hasAnyRole() {
    return (
      this.isAdmin() ||
      this.isAuthorityGroupAdmin() ||
      this.isRelationAdmin() ||
      this.isKindAdmin()
    )
  }

  allowedTo(policy, collections = [], requireAll = true) {
    if (!this.currentUser()) return false

    const perms = this.currentUser().permissions.collections[policy]

    if (Zepto.isArray(collections)) {
      if (collections.length == 0) {
        return perms.length > 0
      } else if (requireAll) {
        return wApp.auth.intersect(perms, collections).length == perms.length
      } else {
        return wApp.auth.intersect(perms, collections).length > 0
      }
    } else {
      return perms.indexOf(collections) != -1
    }
  }
}

wApp.mixins.auth = Object.getPrototypeOf(new AuthMixin())
