<kor-kind-editor>

  <h2>
    <kor-t
      key="objects.edit"
      with={ {'interpolations': {'o': opts.kind.name}} }
    />
  </h2>

  <form onsubmit={submit}>
    
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
      field-id="parent_id"
      type="select"
      options={possible_parents}
      label-key="kind.parent"
      model={opts.kind}
      errors={errors.parent_id}
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
      $.ajax(
        type: 'get'
        url: '/kinds'
        data: {parent_id: 'all'}
        success: (data) ->
          console.log data
          tag.possible_parents = []
          for kind in data.records
            tag.possible_parents.push(
              label: kind.name
              value: kind.id
            )
          tag.update()
      )

    tag.is_media = ->
      opts.kind.uuid == wApp.data.medium_kind_uuid

    tag.values = ->
      result = {}
      for field in tag.tags['kor-field']
        result[field.fieldId()] = field.val()
      result

    tag.submit = (event) ->
      event.preventDefault()
      if tag.opts.kind
        $.ajax(
          type: 'patch'
          url: "/kinds/#{tag.opts.kind.id}"
          data: JSON.stringify(kind: tag.values())
          success: (data) ->
            console.log data
            tag.errors = null
          error: (request) -> 
            data = request.responseJSON
            tag.errors = data.errors
          complete: ->
            tag.update()
        )
      else
        $.ajax(
          type: 'post'
          url: '/kinds'
          data: {kind: tag.values()}
          success: (data) -> console.log data
          error: () -> console.log arguments
        )

  </script>

</kor-kind-editor>