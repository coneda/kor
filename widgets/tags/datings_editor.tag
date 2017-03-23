<kor-datings-editor>

  <div class="header">
    <button onclick={add}>
      {t('verbs.add', {capitalize: true})}
    </button>
    <label>
      {t(
        'activerecord.attributes.relationship.dating.other',
        {capitalize: true}
      )}
    </label>
    <div class="clearfix"></div>
  </div>

  <ul>
    <li
      each={dating, i in opts.datings}
      show={!dating._destroy}
    >
      <kor-input
        label={t('activerecord.attributes.dating.label', {capitalize: true})}
        value={dating.label}
        ref="datingLabels"
      />
      <kor-input
        label={t('activerecord.attributes.dating.dating_string', {capitalize: true})}
        value={dating.value}
        ref="datingDatingStrings"
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

    tag.add = (event) ->
      event.preventDefault()
      tag.opts.datings.push({})
      tag.update()

    tag.remove = (index) ->
      (event) ->
        event.preventDefault()
        dating = tag.opts.datings
        if dating.id
          tag.opts.datings[index]._destroy = true
        else
          tag.opts.datings.splice(index, 1)
        tag.update()

    tag.value = ->
      datingLabels = wApp.utils.toArray(tag.refs['datingLabels'])
      datingDatingStrings = wApp.utils.toArray(tag.refs['datingDatingStrings'])

      for d, i in tag.opts.datings
        d['label'] = datingLabels[i].value()
        d['value'] = datingDatingStrings[i].value()

      tag.opts.datings

  </script>

</kor-datings-editor>