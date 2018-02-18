<kor-field class={'errors': has_errors()}>
  
  <label>
    {label()}
    <input
      if={has_input()}
      type={inputType()}
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
      disabled={opts.isDisabled}
    >
      <option
        if={opts.allowNoSelection}
        value={undefined}
        selected={!!value()}
      >{noSelectionLabel()}</option>
      <option
        each={o in opts.options}
        value={o.value}
        selected={parent.selected(o.value)}
      >{o.label}</option>
    </select>
    <ul if={has_errors()} class="errors">
      <li each={error in errors()}>{error}</li>
    </ul>
  </label>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      if tag.parent
        tag.parent.formFields ||= {}
        tag.parent.formFields[tag.fieldId()] = tag

    tag.on 'unmount', ->
      if tag.parent
        tag.parent.formFields ||= {}
        delete tag.parent.formFields[tag.fieldId()]

    tag.on 'updated', ->
      if tag.has_select()
        Zepto(tag.root).find('select option[selected]').prop('selected', true)

    tag.fieldId = -> tag.opts.fieldId
    tag.label = ->
      if tag.opts.label
        tag.opts.label
      else if tag.opts.labelKey
        keys = [tag.opts.labelKey, "activerecord.attributes.#{tag.opts.labelKey}"]
        for k in keys
          if result = wApp.i18n.t(k, capitalize: true)
            return result
      else
        tag.fieldId()

    tag.inputType = -> opts.type || 'text'
    tag.has_input = -> !tag.has_textarea() && !tag.has_select()
    tag.has_textarea = -> tag.inputType() == 'textarea'
    tag.has_select = -> tag.inputType() == 'select'
    tag.noSelectionLabel = ->
      tag.opts.noSelectionLabel || wApp.i18n.t('nothing_selected')

    tag.checked = -> if tag.inputType() == 'checkbox' then tag.value() else false
    tag.selected = (key) ->
      if tag.value()
        if tag.opts.multiple
          tag.value().indexOf(key) > -1
        else
          tag.value() == key
    tag.value = -> 
      tag.opts.value || if tag.opts.model
        tag.opts.model[tag.opts.fieldId]
      else
        undefined

    tag.errors = ->
      tag.opts.errors ||
      if m = tag.opts.model
        (m.errors || {})[tag.opts.fieldId] || []
      else
        []
    tag.has_errors = -> tag.errors().length > 0

    tag.val = ->
      element = Zepto(tag.root).find('input, textarea, select')
      if tag.inputType() == 'checkbox'
        element.prop('checked')
      else
        element.val()

  </script>

</kor-field>