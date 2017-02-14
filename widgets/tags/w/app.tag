<w-app>

  <div class="w-content" />

  <w-modal />
  <w-messaging />

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      wApp.routing.setup()
    
    wApp.bus.on 'routing:path', (parts) ->
      tagName = null
      opts = {}

      if tagName
        riot.mount Zepto('.w-content')[0], tagName, opts
        window.scrollTo(0, 0)

  </script>

</w-app>