<w-app>

  <div class="w-content" />

  <w-modal />
  <w-messaging />

  <style type="text/scss">
    @import "widgets/app.scss";
  </style>

  <script type="text/coffee">
    self = this

    self.on 'mount', ->
      wApp.routing.setup()
    
    wApp.bus.on 'routing:path', (parts) ->
      tag = null
      opts = {}

      if tag
        riot.mount Zepto('.w-content')[0], tag, opts
        window.scrollTo(0, 0)

  </script>

</w-app>