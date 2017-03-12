<kor-field-editor>

  <h2>
    <kor-t
      key="objects.edit"
      with={ {'interpolations': {'o': wApp.i18n.translate('activerecord.models.field', {count: 'other'})}} }
      show={opts.kind.id}
    />
  </h2>

  <form if={showForm && types} onsubmit={submit}>

    <kor-field
      field-id="type"
      label-key="field.type"
      type="select"
      options={types_for_select}
      allow-no-selection={false}
      model={field}
      onchange={updateSpecialFields}
      is-disabled={field.id}
    />

    <virtual each={f in specialFields}>
      <kor-field
        field-id={f.name}
        label={f.label}
        model={field}
        errors={errors[f.name]}
      />
    </virtual>

    <kor-field
      field-id="name"
      label-key="field.name"
      model={field}
      errors={errors.name}
    />

    <kor-field
      field-id="show_label"
      label-key="field.show_label"
      model={field}
      errors={errors.show_label}
    />

    <kor-field
      field-id="form_label"
      label-key="field.form_label"
      model={field}
      errors={errors.form_label}
    />

    <kor-field
      field-id="search_label"
      label-key="field.search_label"
      model={field}
      errors={errors.search_label}
    />

    <kor-field
      field-id="show_on_entity"
      type="checkbox"
      label-key="field.show_on_entity"
      model={field}
    />

    <kor-field
      field-id="is_identifier"
      type="checkbox"
      label-key="field.is_identifier"
      model={field}
    />

    <div class="hr"></div>

    <kor-submit />
  </form>

  <script type="text/coffee">
    tag = this
    tag.errors = {}

    tag.opts.notify.on 'add-field', ->
      tag.field = {type: 'Fields::String'}
      tag.showForm = true
      tag.updateSpecialFields()

    tag.opts.notify.on 'edit-field', (field) ->
      tag.field = field
      tag.showForm = true
      tag.updateSpecialFields()

    tag.on 'mount', ->
      Zepto.ajax(
        url: "/kinds/#{tag.opts.kind.id}/fields/types"
        success: (data) ->
          tag.types = {}
          tag.types_for_select = []
          for t in data
            tag.types_for_select.push(value: t.name, label: t.label)
            tag.types[t.name] = t
          tag.updateSpecialFields()
      )

    tag.updateSpecialFields = (event) ->
      if tag.showForm
        # get the tag selection or fall back to the model value
        typeName = Zepto('[name=type]').val() || tag.field.type
        # update the model
        tag.field.type = typeName
        if types = tag.types
          tag.specialFields = types[typeName].fields
          tag.update()
      true

    tag.submit = (event) ->
      event.preventDefault()
      if tag.field.id then update() else create()

    params = ->
      results = {}
      for k, t of tag.formFields
        results[t.fieldId()] = t.val()
      return {
        field: results
        klass: results.type
      }


    create = ->
      Zepto.ajax(
        type: 'POST'
        url: "/kinds/#{tag.opts.kind.id}/fields"
        data: JSON.stringify(params())
        success: ->
          tag.opts.notify.trigger 'refresh'
          tag.errors = {}
          tag.showForm = false
        error: (request) ->
          data = JSON.parse(request.response)
          tag.errors = data.record.errors
        complete: ->
          tag.update()
      )

    update = ->
      console.log 'updating'
      Zepto.ajax(
        type: 'PATCH'
        url: "/kinds/#{tag.opts.kind.id}/fields/#{tag.field.id}"
        data: JSON.stringify(params())
        success: ->
          tag.opts.notify.trigger 'refresh'
          tag.showForm = false
        error: (request) ->
          tag.field = request.responseJSON.record
          tag.field.errors = request.responseJSON.errors
        complete: ->
          tag.update()
      )

  </script>

</kor-field-editor>