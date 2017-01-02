<w-app>

  <div class="w-content" />

  <w-modal />
  <w-messaging />

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      console.log(tag)
      wApp.routing.setup()
    
    wApp.bus.on 'routing:path', (parts) ->
      tag = null
      opts = {}

      if tag
        riot.mount Zepto('.w-content')[0], tag, opts
        window.scrollTo(0, 0)

  </script>

</w-app>