<!-- TODO: can this be dropped? -->
<kor-menu-fix>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      wApp.bus.on 'kinds-changed', fixMenu

    tag.on 'unmount', ->
      wApp.bus.off 'kinds-changed', fixMenu

    fixMenu = ->
      Zepto.ajax(
        url: '/kinds'
        data: {only_active: true}
        success: (data) ->
          select = Zepto('#new_entity_kind_id')
          placeholder = select.find('option:first-child').remove()
          select.find('option').remove()
          select.append(placeholder)
          for kind in data.records
            select.append("<option value=\"#{kind.id}\">#{kind.name}</option>")
      )
  </script>

</kor-menu-fix>