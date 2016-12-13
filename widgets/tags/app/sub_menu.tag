<kor-sub-menu>

  <a href="#" onclick={toggle}>{opts.label}</a>
  <div class="content" show={visible()}>
    <yield />
  </div>

  <script type="text/coffee">
    tag = this

    tag.visible = -> (Lockr.get('toggles') || {})[tag.opts.menuId]
    tag.toggle = (event) ->
      event.preventDefault()
      data = Lockr.get('toggles') || {}
      data[tag.opts.menuId] = !data[tag.opts.menuId]
      Lockr.set 'toggles', data
  </script>

</kor-sub-menu>