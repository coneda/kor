<kor-datings-editor>

  <div class="header" if={add}>
    <button onclick={add} class="pull-right" type="button">
      {t('verbs.add', {capitalize: true})}
    </button>
    <label>{opts.label || tcap('activerecord.models.entity_dating', {count: 'other'})}</label>
    <div class="clearfix"></div>
  </div>

  <ul show={anyVisibleDatings()}>
    <li
      each={dating, i in data}
      show={!dating._destroy}
      visible={!dating._destroy}
    >
      <kor-input
        label={t('activerecord.attributes.dating.label', {capitalize: true})}
        ref="labels"
        errors={errorsFor(i, 'label')}
      />
      <kor-input
        label={t('activerecord.attributes.dating.dating_string', {capitalize: true})}
        ref="dating_strings"
        errors={errorsFor(i, 'dating_string')}
      />
      <div class="kor-text-right">
        <button onclick={remove}>
          {t('verbs.delete')}
        </button>
      </div>
      <div class="clearfix"></div>
    </li>
  </ul>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    # tag.on 'mount', ->
    #  tag.update()

    tag.anyVisibleDatings = ->
      for dating in (tag.data || [])
        return true if !dating['_destroy']
      false

    tag.name = -> tag.opts.name

    tag.errorsFor = (i, field) ->
      e = tag.opts.errors || []
      o = e[i] || {}
      o[field]

    tag.set = (values) ->
      tag.data = values
      tag.update()

      labelInputs = wApp.utils.toArray(tag.refs['labels'])
      datingStringInputs = wApp.utils.toArray(tag.refs['dating_strings'])

      for i, dating of tag.data
        labelInputs[i].set(dating['label'])
        datingStringInputs[i].set(dating['dating_string'])

    tag.add = (event) ->
      event.preventDefault()
      tag.data.push(label: tag.opts.defaultDatingLabel)
      tag.set(tag.data)

    tag.remove = (event) ->
      event.preventDefault()
      dating = event.item.dating
      index = event.item.i
      if dating.id
        tag.data[index]._destroy = true
      else
        tag.data.splice(index, 1)
      tag.update()

    tag.value = ->
      labelInputs = wApp.utils.toArray(tag.refs['labels'])
      datingStringInputs = wApp.utils.toArray(tag.refs['dating_strings'])

      for i, dating of tag.data
        dating['label'] = labelInputs[i].value()
        dating['dating_string'] = datingStringInputs[i].value()

      tag.data

  </script>

</kor-datings-editor>