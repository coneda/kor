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
          pageTitleUpdate: (newTitle) ->
            nv = if newTitle then "KOR: #{newTitle}" else 'ConedaKOR'
            Zepto('title').html nv
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
              if m = path.match(/^\/users\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-user-editor'
              else if m = path.match(/^\/entities\/([0-9]+)$/)
                opts['id'] = parseInt(m[1])
                'kor-entity-page'
              else if m = path.match(/^\/kinds\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-kind-editor'
              else if m = path.match(/^\/entities\/new$/)
                opts['kindId'] = parts['hash_query']['kind_id']
                'kor-entity-editor'
              else if m = path.match(/^\/entities\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-entity-editor'
              else
                switch path
                  when '/clipboard'
                    opts.handlers.reset = ->
                      wApp.clipboard.reset()
                      tag.mountedTag.opts.entityIds = wApp.clipboard.ids()
                      Zepto.Deferred().resolve()
                    opts.handlers.remove = (id) ->
                      wApp.clipboard.remove(id)
                      tag.mountedTag.opts.entityIds = wApp.clipboard.ids()
                      Zepto.Deferred().resolve()
                    opts.entityIds = wApp.clipboard.ids()
                    'kor-clipboard'
                  when '/profile' then 'kor-profile'
                  when '/new-media' then 'kor-new-media'
                  when '/users/new' then 'kor-user-editor'
                  when '/users' then 'kor-users'
                  when '/entities/invalid' then 'kor-invalid-entities'
                  when '/entities/recent' then 'kor-recent-entities'
                  when '/entities/isolated' then 'kor-isolated-entities'
                  when '/search' then 'kor-search'
                  when '/kinds' then 'kor-kinds'
                  when '/kinds/new' then 'kor-kind-editor'
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

    # old code
    # tag.on 'mount', -> wApp.routing.setup()
    
    # wApp.bus.on 'routing:path', (parts) ->
    #   opts = {}
    #   tagName = switch parts['hash_path']
    #     when '/some/path'
    #       opts['some'] = parts['hash_query'].value
    #       'some-tag'
    #     else
    #       'some-default-tag'
    #   riot.mount Zepto('.w-content')[0], tagName, opts
    #   window.scrollTo(0, 0)

  </script>

</w-app>