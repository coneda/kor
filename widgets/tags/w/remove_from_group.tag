<kor-remove-from-group>

  <a
    if={isGroupAdmin()}
    title={t('verbs.remove')}
    href="#"
    onClick={remove}
  ><i class="fa fa-minus"></i></a>

  <script type="text/javascript">
    var tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.i18n)

    tag.remove = (event) => {
      event.preventDefault()

      Zepto.ajax({
        type: 'POST',
        url: '/' + tag.opts.type + '_groups/' + tag.opts.groupId + '/remove',
        data: JSON.stringify({
          entity_ids: [tag.opts.entity.id]
        }),
        success: data => {
          wApp.bus.trigger('group-changed')
        }
      })
    }

    tag.isGroupAdmin = () => {
      console.log('xxx', tag.opts.type, tag.isAuthorityGroupAdmin())
      return (tag.opts.type !== 'authority') || tag.isAuthorityGroupAdmin()
    }
  </script>

</kor-remove-from-group>