<kor-new-entity-selector>

  <kor-field
    field-id="new_entity[kind_id]"
    type="select"
    options={possible_kinds}
    label=" "
    allow-no-selection={true}
    no-selection-label={noSelectionLabel()}
    onchange={navigateTo}
  />

  <script type="text/coffee">
    tag = this

    fetch = ->
      Zepto.ajax(
        url: '/kinds'
        success: (data) ->
          tag.possible_kinds = []
          for kind in data.records
            tag.possible_kinds.push(
              label: kind.name
              value: kind.id
            )
          tag.update()
      )
    
    tag.on 'mount', ->
      wApp.bus.on 'kinds-changed', fetch
      fetch()

    tag.noSelectionLabel = ->
      e = wApp.i18n.t('activerecord.models.entity')
      wApp.i18n.t('objects.create', interpolations: {o: e}, capitalize: true)

    tag.navigateTo = (event) ->
      kind_id = tag.tags['kor-field'].val()
      document.location.href = "/entities/new?kind_id=#{kind_id}"

  </script>

</kor-new-entity-selector>