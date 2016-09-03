<w-modal style="display: none">

  <div name="receiver"></div>

  <style type="text/scss">
    w-modal, [data-is=w-modal] {
      position: fixed;
      top: 0px;
      height: 100%;
      left: 0px;
      width: 100%;
      background-color: rgba(0, 0, 0, 0.7);
      z-index: 10000;

      [name=receiver] {
        position: fixed;
        z-index: 10001;
        background-color: white;
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%);
      }
    }
  </style>

  <script type="text/coffee">
    self = this
    self.active = false

    wApp.bus.on 'modal', (tag, opts = {}) ->
      # console.log arguments
      opts.modal = self
      riot.mount self.receiver, tag, opts
      $(self.root).show()
      self.active = true

    $(document).on 'keydown', (event) ->
      if event.key == 'Escape'
        self.trigger 'close'

    self.on 'mount', ->
      $(self.root).on 'click', (event) ->
        if event.target == self.root
          self.trigger 'close'

    self.on 'close', ->
      if self.active
        $(self.root).hide()
        self.active = false

  </script>

</w-modal>