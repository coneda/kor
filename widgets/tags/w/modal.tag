<w-modal style="display: none" onclick={backPanelClick}>

  <div name="receiver">
    <div class="target"></div>
  </div>

  <script type="text/coffee">
    tag = this
    tag.active = false
    window.t = tag

    wApp.bus.on 'modal', (tagName, opts = {}) ->
      opts.modal = tag
      tag.active = true
      tag.innerTag = riot.mount(Zepto(tag.root).find('.target')[0], tagName, opts)[0]
      Zepto(tag.root).show()
      fixHeight()

    tag.backPanelClick = (event) ->
      if event.target == tag.root
        tag.trigger 'close'
      true

    tag.on 'close', ->
      if tag.active
        Zepto(tag.root).hide()
        tag.innerTag.unmount(true)
        tag.active = false

    fixHeight = ->
      new_height = Math.max(Zepto(window).height() - 100, 300)
      Zepto(tag.root).find('[name=receiver]').css 'height', new_height

    Zepto(window).on 'resize', fixHeight
    Zepto(document).on 'keydown', (event) ->
      if event.key == 'Escape'
        tag.trigger 'close'

  </script>

</w-modal>