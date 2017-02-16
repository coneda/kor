<w-app-loader>

  <div class="app"></div>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      preloaders = [
        wApp.session.setup(),
        wApp.i18n.setup(),
        wApp.info.setup(),
        wApp.config.setup()
      ]

      $.when(preloaders...).then ->
        opts = {routing: true}
        riot.mount Zepto(tag.root).find('.app')[0], 'w-app', opts
        console.log 'application loaded'

  </script>

</w-app-loader>