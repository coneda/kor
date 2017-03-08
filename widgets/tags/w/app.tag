<w-app>
  <div class="w-content"></div>

  <w-modal />
  <w-messaging />

  <script type="text/coffee">
    tag = this

    tag.on 'mount', -> wApp.routing.setup()
    
    wApp.bus.on 'routing:path', (parts) ->
      opts = {}
      tagName = switch parts['hash_path']
        when '/some/path'
          opts['some'] = parts['hash_query'].value
          'some-tag'
        else
          'some-default-tag'
      riot.mount Zepto('.w-content')[0], tagName, opts
      window.scrollTo(0, 0)

  </script>
</w-app>