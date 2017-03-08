<w-modal show={isActive}>

  <div class="receiver" ref="receiver"></div>

  <script type="text/coffee">
    tag = this

    wApp.bus.on 'modal', (tagName, opts = {}) ->
      opts.modal = tag
      tag.mountedTag = riot.mount(tag.refs.receiver, tagName, opts)[0]
      tag.isActive = true
      tag.update()

    Zepto(document).on 'keydown', (event) ->
      if tag.isActive && event.key == 'Escape'
        tag.trigger 'close'

    tag.on 'mount', ->
      tag.isActive = false
      tag.mountedTag = null

      Zepto(tag.root).on 'click', (event) ->
        if tag.isActive && event.target == tag.root
          tag.trigger 'close'

    tag.on 'close', ->
      if tag.isActive
        tag.isActive = false
        tag.mountedTag.unmount(true)
        tag.update()

  </script>

</w-modal>