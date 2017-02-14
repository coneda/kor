<w-modal show={active}>

  <div class="receiver" ref="receiver"></div>

  <script type="text/coffee">
    tag = this
    tag.active = false
    tag.mountedTag = null

    wApp.bus.on 'modal', (tagName, opts = {}) ->
      opts.modal = tagName
      tag.mountedTag = riot.mount(tag.refs.receiver, tagName, opts)[0]
      tag.active = true
      tag.update()

    Zepto(document).on 'keydown', (event) ->
      if tag.active && event.key == 'Escape'
        tag.trigger 'close'

    tag.on 'mount', ->
      Zepto(tag.root).on 'click', (event) ->
        if tag.active && event.target == tag.root
          tag.trigger 'close'

    tag.on 'close', ->
      if tag.active
        tag.active = false
        tag.mountedTag.unmount(true)
        tag.update()

  </script>

</w-modal>