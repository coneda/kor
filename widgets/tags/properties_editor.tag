<kor-properties-editor>

  <div class="header">
    <button onclick={add}>
      {t('verbs.add', {capitalize: true})}
    </button>
    <label>
      {t(
        'activerecord.attributes.relationship.property.other',
        {capitalize: true}
      )}
    </label>
    <div class="clearfix"></div>
  </div>

  <ul>
    <li each={property, i in properties}>
      <kor-input
        value={property.value}
        ref="inputs"
      />
      <button onclick={remove(i)}>
        {t('verbs.remove')}
      </button>
    </li>
  </ul>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'mount', ->
      tag.properties = []
      for p in tag.opts.properties
        tag.properties.push(value: p)

    tag.add = (event) ->
      event.preventDefault()
      tag.properties.push(value: "")
      tag.update()

    tag.remove = (index) ->
      (event) ->
        event.preventDefault()
        tag.properties.splice(index, 1)
        tag.update()

    tag.value = -> e.value() for e in wApp.utils.toArray(tag.refs.inputs)

  </script>

</kor-properties-editor>