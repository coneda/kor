<w-modal style="display: none">

  <div name="receiver"></div>

  <script type="text/coffee">
    self = this
    self.active = false

    wApp.bus.on 'modal', (tag, opts = {}) ->
      opts.modal = self
      riot.mount self.receiver, tag, opts
      Zepto(self.root).show()
      self.active = true

    Zepto(document).on 'keydown', (event) ->
      if event.key == 'Escape'
        self.trigger 'close'

    self.on 'mount', ->
      Zepto(self.root).on 'click', (event) ->
        if event.target == self.root
          self.trigger 'close'

    self.on 'close', ->
      if self.active
        Zepto(self.root).hide()
        self.active = false

  </script>

</w-modal>