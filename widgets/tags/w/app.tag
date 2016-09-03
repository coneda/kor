<w-app>

  <div class="w-content"></div>

  <w-modal />
  <w-messaging />

  <style type="text/scss">
    @import "widgets/styles/vars.scss";
  </style>

  <script type="text/coffee">
    self = this

    self.on 'mount', -> wApp.routing.setup()
    
    wApp.bus.on 'routing:path', (parts) ->
      opts = {}
      tag = switch parts['hash_path']
        when '/some/path'
          opts['some'] = parts['hash_query'].value
          'some-tag'
        else
          'some-default-tag'
      riot.mount $('.w-content')[0], tag, opts
      window.scrollTo(0, 0)

  </script>

</w-app>