<kor-kind-general-editor>

  <h2>
    <kor-t
      key="objects.edit"
      with={ {'interpolations': {'o': opts.kind.name}} }
      show={opts.kind.id}
    />
    <kor-t
      show={!opts.kind.id}
      key="objects.create"
      with={ {'interpolations': {'o': wApp.i18n.translate('activerecord.models.kind')}} }
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

      $.ajax(
        type: 'get'
        url: '/kinds'
        success: (data) ->
          tag.possible_parents = []
          for kind in data.records
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
      wApp.bus.trigger 'kinds-changed'
      tag.update()

    error = (response) ->
      data = response.responseJSON
      console.log data
      tag.errors = data.errors
      tag.opts.kind = data.record
      tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      if tag.new_record()
        $.ajax(
          type: 'post'
          url: '/kinds'
          data: JSON.stringify(kind: tag.values())
          success: success
          error: error
        )
      else
        $.ajax(
          type: 'patch'
          url: "/kinds/#{tag.opts.kind.id}"
          data: JSON.stringify(kind: tag.values())
          success: success
          error: error
        )

  </script>

</kor-kind-general-editor>