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
      success: (data) -> wApp.bus.trigger('reload-session')
    )
  logout: ->
    Zepto.ajax(
      type: 'delete'
      url: '/logout'
      success: (data) ->
        wApp.bus.trigger('reload-session')
        wApp.routing.path('/')
    )
}

wApp.mixins.auth = {
  hasRole: (roles) ->
    return false unless this.currentUser()
    
    roles = [roles] unless Zepto.isArray(roles)
    for role in roles
      return false unless this.currentUser().permissions.roles[role]
    
    true
  hasAnyRole: ->
    return false unless this.currentUser()

    perms = this.currentUser().permissions.roles
    for k, v of perms
      return true if v
    false
  allowedTo: (policy, collections = [], requireAll = true) ->
    return false unless this.currentUser()

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
