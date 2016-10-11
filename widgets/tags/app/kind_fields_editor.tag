<kor-kind-fields-editor>

  <div class="pull-right">
    <a href="#/kinds/{kind.id}/fields/new" onclick={add}>
      <i class="fa fa-plus-square"></i>
    </a>
  </div>

  <h2>
    <kor-t
      key="objects.edit"
      with={ {'interpolations': {'o': wApp.i18n.translate('activerecord.models.field', {count: 'other'})}} }
      show={opts.kind.id}
    />
  </h2>

  <form show={showForm}>

    <kor-field
      field-id="type"
      label-key="field.type"
      type="select"
      options={types_for_select}
      model={field}
      onchange={updateSpecialFields}
    />

    <virtual each={f in special_fields}>
      <kor-field
        field-id={f.name}
        label={f.label}
        model={field}
        errors={field.errors[f.name]}
      />
    </virtual>

    <kor-field
      field-id="name"
      label-key="field.name"
      model={field}
      errors={field.errors.name}
    />

    <kor-field
      field-id="show_label"
      label-key="field.show_label"
      model={field}
      errors={field.errors.show_label}
    />

    <kor-field
      field-id="form_label"
      label-key="field.form_label"
      model={field}
      errors={field.errors.form_label}
    />

    <kor-field
      field-id="search_label"
      label-key="field.search_label"
      model={field}
      errors={field.errors.search_label}
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

  <h3>Direct fields</h3>

  <ul>
    <li each={field in kind.fields}>
      
    </li>
  </ul>


  <script type="text/coffee">
    tag = this
    tag.showForm = true

    tag.updateSpecialFields = (event) ->
      selectedType = $(event.target).val()
      type = tag.types[selectedType]
      tag.special_fields = type.fields
      tag.update()
      true

    tag.params = ->
      results = {}
      for f in tag.tags['kor-field']
        results[f.opts.fieldId] = f.val()
      results

    tag.add = (event) ->
      event.preventDefault()
      tag.field = {}
      tag.showForm = true
      tag.update()

    tag.on 'mount', ->
      $(tag.root).find('kor-field:first-child').on 'change', 'select', (event) ->
        true

      $.ajax(
        url: "/kinds/#{tag.opts.kind.id}/fields/types"
        success: (data) ->
          tag.types = {}
          tag.types_for_select = []
          for t in data
            tag.types_for_select.push(value: t.name, label: t.label)
            tag.types[t.name] = t
      )

      $.ajax(
        type: 'get'
        url: "/kinds/#{tag.opts.kind.id}"
        data: {include: ['fields', 'ancestry']}
        success: (data) ->
          tag.kind = data
          tag.update()
      )
  </script>

</kor-kind-fields-editor>