<kor-field class={'errors': opts.errors}>
  
  <label>
    {label()}
    <input
      if={has_input()}
      type={type()}
      name={opts.fieldId}
      value={value()}
      checked={checked()}
    />
    <textarea
      if={has_textarea()}
      name={opts.fieldId}
    >{value()}</textarea>
    <select
      if={has_select()}
      name={opts.fieldId}
      multiple={opts.multiple}
    >
      <option selected={!!value()}>{wApp.i18n.t('nothing_selected')}</option>
      <option
        each={o in opts.options}
        value={o.value}
        selected={parent.selected(o.value)}
      >{o.label}</option>
    </select>
    <ul if={opts.errors} class="errors">
      <li each={error in opts.errors}>{error}</li>
    </ul>
  </label>

  <script type="text/coffee">
    tag = this

    tag.fieldId = -> tag.opts.fieldId
    tag.label = ->
      keys = [tag.opts.labelKey, "activerecord.attributes.#{tag.opts.labelKey}"]
      for k in keys
        if result = wApp.i18n.t(k, capitalize: true)
          return result


    tag.type = -> opts.type || 'text'
    tag.has_input = -> !tag.has_textarea() && !tag.has_select()
    tag.has_textarea = -> tag.type() == 'textarea'
    tag.has_select = -> tag.type() == 'select'

    tag.checked = -> if tag.type() == 'checkbox' then tag.value() else false
    tag.selected = (key) -> tag.value() == key
    tag.value = -> tag.opts.value || tag.opts.model[tag.opts.fieldId]

    tag.val = ->
      element = $(tag.root).find('input, textarea, select')
      if tag.type() == 'checkbox'
        element.prop('checked')
      else
        element.val()

  </script>

</kor-field>