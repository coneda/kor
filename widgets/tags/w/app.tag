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

    tag.on 'mount', ->
      wApp.bus.on 'routing:path', tag.routeHandler
      if tag.opts.routing
        wApp.routing.setup()

    tag.on 'unmount', ->
      wApp.bus.off 'routing:path', tag.routeHandler
      if tag.opts.routing
        wApp.routing.tearDown()

    tag.routeHandler = (parts) ->
      tagName = 'kor-loading'
      opts = {}

      if tag.currentUser() && !tag.isGuest() && parts.hash_path == '/login'
        wApp.routing.path '/search'
      else
        tagName = switch parts.hash_path
          when '/login' then 'kor-login'
          when '/stats' then 'kor-stats'
          when '/legal' then 'kor-legal'
          when '/about' then 'kor-about'
          else
            if tag.currentUser()
              if !tag.isGuest() && !tag.currentUser().terms_accepted && parts.hash_path != '/legal'
                wApp.routing.path '/legal'
                null
              else
                switch parts.hash_path
                  when 'search' then 'kor-search'
                  when 'gallery' then 'kor-gallery'
                  else
                    'kor-search'
            else
              'kor-login'

        if tagName
          riot.mount Zepto('.w-content')[0], tagName, opts
          window.scrollTo(0, 0)

  </script>

</w-app>