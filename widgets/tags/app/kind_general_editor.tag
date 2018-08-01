<kor-kind-general-editor>

  <h2 if={opts.kind}>
    <kor-t
      key="general"
      with={ {capitalize: true} }
      show={opts.kind.id}
    />
    <kor-t
      show={!opts.kind.id}
      key="objects.create"
      with={ {'interpolations': {'o': wApp.i18n.translate('activerecord.models.kind')}} }
    />
  </h2>

  <form onsubmit={submit} if={possible_parents}>

    <kor-field
      field-id="schema"
      label-key="kind.schema"
      model={opts.kind}
    />
    
    <kor-field
      field-id="name"
      label-key="kind.name"
      model={opts.kind}
      errors={errors.name}
    />

    <kor-field
      field-id="plural_name"
      label-key="kind.plural_name"
      model={opts.kind}
      errors={errors.plural_name}
    />

    <kor-field
      field-id="description"
      type="textarea"
      label-key="kind.description"
      model={opts.kind}
    />

    <kor-field
      field-id="url"
      label-key="kind.url"
      model={opts.kind}
    />

    <kor-field
      field-id="parent_ids"
      type="select"
      options={possible_parents}
      multiple={true}
      label-key="kind.parent"
      model={opts.kind}
      errors={errors.parent_ids}
    />

    <kor-field
      field-id="abstract"
      type="checkbox"
      label-key="kind.abstract"
      model={opts.kind}
    />

    <kor-field
      field-id="tagging"
      type="checkbox"
      label-key="kind.tagging"
      model={opts.kind}
    />

    <div if={!is_media()}>
      <kor-field
        field-id="dating_label"
        label-key="kind.dating_label"
        model={opts.kind}
      />

      <kor-field
        field-id="name_label"
        label-key="kind.name_label"
        model={opts.kind}
      />

      <kor-field
        field-id="distinct_name_label"
        label-key="kind.distinct_name_label"
        model={opts.kind}
      />
    </div>

    <div class="hr"></div>

    <kor-submit />

  </form>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      # tag.opts.kind ||= {}
      tag.errors = {}

      Zepto.ajax(
        type: 'get'
        url: '/kinds'
        success: (data) ->
          tag.possible_parents = []
          for kind in data.records
            if !tag.opts.kind || (tag.opts.kind.id != kind.id && tag.opts.kind.id != 1)
              tag.possible_parents.push(
                label: kind.name
                value: kind.id
              )
          tag.update()
      )

    tag.is_media = ->
      opts.kind &&
      opts.kind.uuid == wApp.data.medium_kind_uuid

    tag.new_record = -> !(tag.opts.kind || {}).id

    tag.values = ->
      result = {}
      for field in tag.tags['kor-field']
        result[field.fieldId()] = field.val()
      result

    success = (data) ->
      tag.parent.trigger 'kind-changed', data.record
      tag.errors = {}
      tag.update()

    error = (response) ->
      data = JSON.parse(response.response)
      tag.errors = data.errors
      tag.opts.kind = data.record
      tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      if tag.new_record()
        Zepto.ajax(
          type: 'POST'
          url: '/kinds'
          data: JSON.stringify(kind: tag.values())
          success: success
          error: error
        )
      else
        Zepto.ajax(
          type: 'PATCH'
          url: "/kinds/#{tag.opts.kind.id}"
          data: JSON.stringify(kind: tag.values())
          success: success
          error: error
        )

  </script>

</kor-kind-general-editor>