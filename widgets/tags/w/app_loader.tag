<w-app-loader>

  <div class="app"></div>

  <script type="text/coffee">
    tag = this

    reloadApp = ->
      if tag.mountedApp
        tag.mountedApp.unmount(true)

      preloaders = wApp.setup()
      $.when(preloaders...).then ->
        element = Zepto(tag.root).find('.app')[0]
        opts = {routing: true}
        tag.mountedApp = riot.mount(element, 'w-app', opts)[0]
        console.log 'application (re)loaded'

    wApp.bus.on 'reload-app', reloadApp
    tag.on 'mount', -> wApp.bus.trigger 'reload-app'

  </script>

</w-app-loader>