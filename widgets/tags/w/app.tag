<w-app>
  <kor-header />
  
  <div>
    <kor-menu />
    <div class="w-content" />
    <kor-footer />
  </div>

  <w-modal ref="modal" />
  <w-messaging />

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.auth)

    window.kor = tag

    tag.on 'mount', ->
      wApp.bus.on 'routing:path', tag.routeHandler
      wApp.bus.on 'routing:query', tag.queryHandler
      wApp.bus.on 'page-title', pageTitleHandler
      wApp.bus.on 'access-denied', accessDenied
      wApp.bus.on 'go-back', goBack
      wApp.bus.on 'query-update', queryUpdate
      wApp.bus.on 'server-code', serverCodeHandler
      if tag.opts.routing
        wApp.routing.setup()

    tag.on 'unmount', ->
      wApp.bus.off 'page-title', pageTitleHandler
      wApp.bus.off 'routing:query', tag.queryHandler
      wApp.bus.off 'routing:path', tag.routeHandler
      wApp.bus.off 'access-denied', accessDenied
      wApp.bus.off 'go-back', goBack
      wApp.bus.off 'query-update', queryUpdate
      wApp.bus.off 'server-code', serverCodeHandler
      if tag.opts.routing
        wApp.routing.tearDown()

    pageTitleHandler = (newTitle) ->
      nv = if newTitle then newTitle else 'ConedaKOR'
      Zepto('head title').html nv

    accessDenied = -> tag.mountTag 'kor-access-denied'
    serverCodeHandler = (code) ->
      if code == 'terms-not-accepted'
        redirectTo '/legal'
        # tag.mountTag 'kor-legal'
    goBack = -> wApp.routing.back()
    queryUpdate = (newQuery) -> wApp.routing.query(newQuery)

    tag.routeHandler = (parts) ->
      tagName = 'kor-loading'
      opts = {
        query: parts['hash_query']
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
        when '/statistics' then 'kor-statistics'
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
              else if m = path.match(/^\/kinds\/([0-9]+)\/edit\/fields\/new$/)
                opts['id'] = parseInt(m[1])
                opts['newField'] = true
                'kor-kind-editor'
              else if m = path.match(/^\/kinds\/([0-9]+)\/edit\/fields\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                opts['fieldId'] = parseInt(m[2])
                'kor-kind-editor'
              else if m = path.match(/^\/kinds\/([0-9]+)\/edit\/generators\/new$/)
                opts['id'] = parseInt(m[1])
                opts['newGenerator'] = true
                'kor-kind-editor'
              else if m = path.match(/^\/kinds\/([0-9]+)\/edit\/generators\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                opts['generatorId'] = parseInt(m[2])
                'kor-kind-editor'
              else if m = path.match(/^\/kinds\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-kind-editor'
              # TODO: can this be done somewhere else? smarter?
              else if m = path.match(/^\/entities\/new$/)
                opts['kindId'] = parts['hash_query']['kind_id']
                opts['cloneId'] = parts['hash_query']['clone_id']
                'kor-entity-editor'
              else if m = path.match(/^\/entities\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-entity-editor'
              else if m = path.match(/^\/credentials\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-credential-editor'
              else if m = path.match(/^\/collections\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-collection-editor'
              else if m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/new$/)
                opts['parentId'] = parseInt(m[1])
                'kor-admin-group-category-editor'
              else if m = path.match(/^\/groups\/categories\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-admin-group-category-editor'
              else if m = path.match(/^\/groups\/categories(?:\/([0-9]+))?$/)
                if m[1]
                  opts['parentId'] = parseInt(m[1])
                'kor-admin-group-categories'
              else if m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/admin\/([0-9]+)\/edit$/)
                opts['categoryId'] = parseInt(m[1])
                opts['id'] = parseInt(m[2])
                'kor-admin-group-editor'
              else if m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/admin\/new$/)
                opts['categoryId'] = parseInt(m[1])
                'kor-admin-group-editor'
              else if m = path.match(/^\/groups\/admin\/([0-9]+)$/)
                opts['id'] = parseInt(m[1])
                opts['type'] = 'authority'
                'kor-entity-group'
              else if m = path.match(/^\/groups\/user\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-user-group-editor'
              else if m = path.match(/^\/groups\/user\/([0-9]+)$/)
                opts['id'] = parseInt(m[1])
                opts['type'] = 'user'
                'kor-entity-group'
              else if m = path.match(/^\/relations\/([0-9]+)\/edit$/)
                opts['id'] = parseInt(m[1])
                'kor-relation-editor'
              else if m = path.match(/^\/media\/([0-9]+)$/)
                opts['id'] = parseInt(m[1])
                'kor-medium-page'
              else if m = path.match(/^\/pub\/([0-9]+)\/([0-9a-f]+)$/)
                opts['userId'] = parseInt(m[1])
                opts['uuid'] = m[2]
                'kor-publishment'
              else
                switch path
                  when '/clipboard' then 'kor-clipboard'
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
                  when '/credentials' then 'kor-credentials'
                  when '/credentials/new' then 'kor-credential-editor'
                  when '/collections' then 'kor-collections'
                  when '/collections/new' then 'kor-collection-editor'
                  when '/upload' then 'kor-upload'
                  when '/groups/user/new' then 'kor-user-group-editor'
                  when '/groups/user' then 'kor-user-groups'
                  when '/groups/shared'
                    opts['type'] = 'shared'
                    'kor-user-groups'
                  when '/relations/new' then 'kor-relation-editor'
                  when '/relations' then 'kor-relations'
                  when '/settings' then 'kor-settings-editor'
                  when '/password-recovery' then 'kor-password-recovery'
                  when '/groups/published' then 'kor-publishments'
                  when '/groups/published/new' then 'kor-publishment-editor'
                  else
                    'kor-search'
          else
            'kor-login'

      tag.closeModal()
      tag.mountTagAndAnimate tagName, opts

    tag.queryHandler = (parts) ->
      if tag.mountedTag
        tag.mountedTag.opts.query = parts['hash_query']
        tag.mountedTag.trigger 'routing:query'

    tag.closeModal = ->
      tag.refs.modal.trigger 'close'

    tag.mountTagAndAnimate = (tagName, opts = {}) ->
      if tagName
        element = Zepto(tag.root).find('.w-content')

        mountIt = ->
          wApp.bus.trigger 'page-title'
          tag.mountedTag = riot.mount(element[0], tagName, opts)[0]
          if wApp.info.data.env != 'test'
            element.animate {opacity: 1.0}, 200
          wApp.utils.scrollToTop()

        if tag.mountedTag
          if wApp.info.data.env != 'test'
            element.animate {opacity: 0.0}, 200, ->
              tag.mountedTag.unmount(true)
              mountIt()
          else
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