<kor-relation-selector>

  <kor-input
    type="select"
    options={relationNames}
    value={opts.riotValue}
    ref="input"
  >

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'criteria-changed', ->
      Zepto.ajax(
        url: '/relations/names'
        data: {
          from_kind_ids: tag.opts.sourceKindId
          to_kind_ids: tag.opts.targetKindId
        }
        success: (data) ->
          tag.relationNames = data
          tag.update()
      )

    tag.value = -> tag.refs.input.value()

  </script>

</kor-relation-selector>