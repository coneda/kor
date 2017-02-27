<w-app>

  <kor-header />
  
  <div>
    <kor-menu />
    <div class="w-content" ref="content" />
  </div>

  <w-modal />
  <w-messaging />

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', ->
      wApp.bus.on 'routing:path', tag.routeHandler
      wApp.bus.on 'routing:query', tag.queryHandler
      if tag.opts.routing
        wApp.routing.setup()

    tag.on 'unmount', ->
      wApp.bus.off 'routing:query', tag.queryHandler
      wApp.bus.off 'routing:path', tag.routeHandler
      if tag.opts.routing
        wApp.routing.tearDown()

    tag.routeHandler = (parts) ->
      tagName = 'kor-loading'
      opts = {
        query: parts['hash_query']
        handlers: {
          accessDenied: -> tag.mountTag 'kor-access-denied'
          queryUpdate: (newQuery) -> wApp.routing.query(newQuery)
          doneHandler: -> wApp.routing.back()
        }
      }

      path = parts['hash_path']
      tagName = switch path
        when undefined, '', '/'
          'kor-welcome'
        when '/login'
          if tag.currentUser() && !tag.isGuest()
            redirectTo '/search'
          else
            'kor-login'
        when '/stats' then 'kor-stats'
        when '/legal' then 'kor-legal'
        when '/about' then 'kor-about'
        else
          if tag.currentUser()
            if !tag.isGuest() && !tag.currentUser().terms_accepted && path != '/legal'
              redirectTo '/legal'
            else
              if m = path.match(/\/users\/([0-9]+)\/edit/)
                opts['id'] = parseInt(m[1])
                'kor-user-editor'
              else
                switch path
                  when '/search' then 'kor-search'
                  when '/new-media' then 'kor-new-media'
                  when '/users' then 'kor-users'
                  when '/entities/invalid' then 'kor-invalid-entities'
                  when '/entities/recent' then 'kor-recent-entities'
                  when '/entities/isolated' then 'kor-isolated-entities'
                  else
                    'kor-search'
          else
            'kor-login'
      tag.mountTagAndAnimate tagName, opts

    tag.queryHandler = (parts) ->
      if tag.mountedTag
        tag.mountedTag.opts.query = parts['hash_query']
        tag.mountedTag.trigger 'routing:query'

    tag.mountTagAndAnimate = (tagName, opts = {}) ->
      if tagName
        element = Zepto('.w-content')

        mountIt = ->
          tag.mountedTag = riot.mount(element[0], tagName, opts)[0]
          element.animate {opacity: 1.0}, 200
          wApp.utils.scrollToTop()

        if tag.mountedTag
          element.animate {opacity: 0.0}, 200, ->
            tag.mountedTag.unmount(true)
            mountIt()
        else
          mountIt()

    tag.mountTag = (tagName, opts = {}) ->
      if tagName
        element = Zepto('.w-content')
        tag.mountedTag.unmount(true) if tag.mountedTag
        tag.mountedTag = riot.mount(element[0], tagName, opts)[0]
        wApp.utils.scrollToTop()

    redirectTo = (new_path) ->
      wApp.routing.path new_path
      null


  </script>

</w-app>