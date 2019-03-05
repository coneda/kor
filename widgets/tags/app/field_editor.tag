<kor-field-editor>
  <h2 if={opts.id}>
    {tcap('objects.edit', {interpolations: {o: 'activerecord.models.field'}})}
  </h2>
  <h2 if={!opts.id}>
    {tcap('objects.create', {interpolations: {o: 'activerecord.models.field'}})}
  </h2>

  <form if={data && types} onsubmit={submit}>

    <kor-input
      name="type"
      label={tcap('activerecord.attributes.field.type')}
      type="select"
      options={types_for_select}
      value={data.type}
      is-disabled={data.id}
      ref="type"
      onchange={updateSpecialFields}
    />

    <virtual each={f in specialFields}>
      <kor-input
        name={f.name}
        label={tcap('activerecord.attributes.field.' + f.name)}
        type={f.type}
        options={f.options}
        riot-value={data[f.name]}
        errors={errors[f.name]}
        ref="fields"
      />
    </virtual>

    <kor-input
      name="name"
      label={tcap('activerecord.attributes.field.name')}
      riot-value={data.name}
      errors={errors.name}
      ref="fields"
    />

    <kor-input
      name="show_label"
      label={tcap('activerecord.attributes.field.show_label')}
      riot-value={data.show_label}
      errors={errors.show_label}
      ref="fields"
    />

    <kor-input
      name="form_label"
      label={tcap('activerecord.attributes.field.form_label')}
      riot-value={data.form_label}
      errors={errors.form_label}
      ref="fields"
    />

    <kor-input
      name="search_label"
      label={tcap('activerecord.attributes.field.search_label')}
      riot-value={data.search_label}
      errors={errors.search_label}
      ref="fields"
    />

    <kor-input
      name="show_on_entity"
      type="checkbox"
      label={tcap('activerecord.attributes.field.show_on_entity')}
      riot-value={data.show_on_entity}
      ref="fields"
    />

    <kor-input
      name="is_identifier"
      type="checkbox"
      label={tcap('activerecord.attributes.field.is_identifier')}
      riot-value={data.is_identifier}
      ref="fields"
    />

    <div class="hr"></div>

    <kor-input
      type="submit"
      value={tcap('verbs.save')}
    />
  </form>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.errors = {}

    tag.on 'mount', ->
      p = [fetchTypes()]

      if tag.opts.id
        p.push fetch()
      else
        tag.data = {type: 'Fields::String'}
        tag.update()

      Zepto.when.apply(null, p).then(tag.updateSpecialFields)

    # TODO: do we still need this?
    # tag.opts.notify.on 'add-field', ->
    #   tag.field = {type: 'Fields::String'}
    #   tag.showForm = true
    #   tag.update()
      # tag.updateSpecialFields()

    # TODO: do we still need this?
    # tag.opts.notify.on 'edit-field', (field) ->
    #   tag.field = field
    #   tag.showForm = true
    #   tag.update()
      # tag.updateSpecialFields()

    tag.updateSpecialFields = (event) ->
      if tag.refs.type
        typeName = tag.refs.type.value()
        if typeName
          if types = tag.types
            tag.specialFields = types[typeName].fields
            tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.done (data) ->
        tag.errors = {}
        tag.opts.notify.trigger 'refresh'
        route("/kinds/#{tag.opts.kindId}/edit")
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: "/kinds/#{tag.opts.kindId}/fields"
        data: JSON.stringify(params())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/kinds/#{tag.opts.kindId}/fields/#{tag.opts.id}"
        data: JSON.stringify(params())
      )

    params = ->
      results = {
        type: tag.refs.type.value()
      }
      for k, t of tag.refs.fields
        results[t.name()] = t.value()
      return {
        field: results
        klass: results.type
      }

    fetch = ->
      Zepto.ajax(
        url: "/kinds/#{tag.opts.kindId}/fields/#{tag.opts.id}"
        success: (data) ->
          tag.data = data
          tag.update()
      )

    fetchTypes = ->
      Zepto.ajax(
        url: "/fields/types"
        success: (data) ->
          tag.types = {}
          tag.types_for_select = []
          for t in data
            tag.types_for_select.push(value: t.name, label: t.label)
            tag.types[t.name] = t
          tag.update()
          # tag.updateSpecialFields()
      )

  </script>
</kor-field-editor>