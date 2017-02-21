wApp.auth = {
  intersect: (a, b) ->
    [a, b] = [b, a] if a.length > b.length
    value for value in a when value in b
  login: (username, password) ->
    Zepto.ajax(
      type: 'post'
      url: '/login'
      data: JSON.stringify(
        username: username,
        password: password
      )
    )
  logout: ->
    Zepto.ajax(
      type: 'delete'
      url: '/logout'
    )
}

wApp.mixins.auth = {
  hasRole: (roles) ->
    roles = [roles] unless Zepto.isArray(roles)
    perms = this.currentUser().permissions.roles
    wApp.auth.intersect(roles, perms).length == roles.length
  hasAnyRole: ->
    perms = this.currentUser().permissions.roles
    perms.length > 0
  allowedTo: (policy, collections = [], requireAll = true) ->
    perms = this.currentUser().permissions.collections[policy]

    if Zepto.isArray(collections)
      if collections.length == 0
        perms.length > 0
      else
        if requireAll
          perms.length == collections.length &&
          wApp.auth.intersect(perms, collections).length == perms.length
        else
          wApp.auth.intersect(perms, collections).length > 0
    else
      perms.indexOf(collections) != -1
}
