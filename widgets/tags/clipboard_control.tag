<kor-clipboard-control>

  <a onclick={toggle}>
    <i class="target_hit" show={isIncluded()}></i>
    <i class="target" show={!isIncluded()}></i>
  </a>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)

    tag.isIncluded = -> wApp.clipboard.includes(tag.opts.entity.id)
    tag.toggle = (event) ->
      event.preventDefault()
      if tag.isIncluded()
        wApp.clipboard.remove tag.opts.entity.id
        wApp.bus.trigger('message',
          'notice', tag.t('objects.unmarked_entity_success')
        )
      else
        if wApp.clipboard.ids().length <= 500
          wApp.clipboard.add tag.opts.entity.id
          wApp.bus.trigger('message',
            'notice', tag.t('objects.marked_entity_success')
          )
        else
          wApp.bus.trigger('message',
            'error', tag.t('errors.clipboard_too_many_elements')
          )
      tag.update()
  </script>

</kor-clipboard-control>