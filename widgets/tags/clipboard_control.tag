<kor-clipboard-control>

  <a
    onclick={toggle}
    if={!isGuest()}
    class="to-clipboard"
    title={t('add_to_clipboard')}
  >
    <i class="target_hit" show={isIncluded()}></i>
    <i class="target" show={!isIncluded()}></i>
  </a>
  <a
    onclick={toggleSelection}
    if={!isGuest()}
    class="make-current"
    title={t('verbs.mark')}
  >
    <i class="select_hit" show={isSelected()}></i>
    <i class="select" show={!isSelected()}></i>
  </a>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', ->
      wApp.bus.on 'clipboard-changed', tag.update
    
    tag.on 'unmount', ->
      wApp.bus.off 'clipboard-changed', tag.update

    tag.isIncluded = -> wApp.clipboard.includes(tag.opts.entity.id)
    tag.isSelected = -> wApp.clipboard.selected(tag.opts.entity.id)

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

    tag.toggleSelection = (event) ->
      event.preventDefault()
      unless tag.isSelected()
        wApp.clipboard.select tag.opts.entity.id
        wApp.bus.trigger('message',
          'notice', tag.t('objects.marked_as_current_success')
        )
        tag.update()

  </script>

</kor-clipboard-control>