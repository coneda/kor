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

    tag.routeHandler = (parts) ->
      tagName = 'kor-loading'
      opts = {}

      tagName = if tag.currentUser()
        if parts.hash_path == '/login'
          'kor-login'
        else
          'kor-search'
      else
        'kor-login'
          
      riot.mount Zepto('.w-content')[0], tagName, opts
      window.scrollTo(0, 0)

  </script>

</w-app>