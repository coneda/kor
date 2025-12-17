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
        selected={selected(o.value)}
      >{o.label}</option>
    </select>
    <ul if={has_errors()} class="errors">
      <li each={error in errors()}>{error}</li>
    </ul>
  </label>

  <script>
    let tag = this

    tag.on('mount', () => {
      // TODO: we should not be doing this!
      if (tag.parent) {
        tag.parent.formFields ||= {}
        tag.parent.formFields[tag.fieldId()] = tag
      }
    })

    tag.on('unmount', () => {
      // TODO: we should not be doing this!
      if (tag.parent) {
        tag.parent.formFields ||= {}
        delete tag.parent.formFields[tag.fieldId()]
      }
    })

    tag.on('updated', () => {
      if (tag.has_select()) {
        Zepto(tag.root).find('select option[selected]').prop('selected', true)
      }
    })

    tag.fieldId = () => tag.opts.fieldId
    tag.label = () => {
      if (tag.opts.label) tag.opts.label
      else if (tag.opts.labelKey) {
        const keys = [tag.opts.labelKey, "activerecord.attributes.#{tag.opts.labelKey}"]
        for (const k of keys) {
          const result = wApp.i18n.t(k, {capitalize: true})
          if (result) return result
        }
      } else {
        return tag.fieldId()
      }
    }

    tag.inputType = () => opts.type || 'text'
    tag.has_input = () => !tag.has_textarea() && !tag.has_select()
    tag.has_textarea = () => tag.inputType() == 'textarea'
    tag.has_select = () => tag.inputType() == 'select'
    tag.noSelectionLabel = () => {
      return (tag.opts.noSelectionLabel || wApp.i18n.t('nothing_selected'))
    }

    tag.checked = () => tag.inputType() == 'checkbox' ? tag.value() : false
    tag.selected = (key) => {
      const v = (tag.opts.model ? tag.opts.model[tag.opts.fieldId] : tag.opts.riotValue)
      if (v && tag.opts.multiple) {
        return v.indexOf(key) > -1
      } else {
        return v == key
      }
    }
    tag.value = () => {
      if (tag.opts.value) return tag.opts.value
      
      return (
        tag.opts.model ?
        tag.opts.model[tag.opts.fieldId] :
        undefined
      )
    }

    tag.errors = () => {
      if (tag.opts.errors) return tag.opts.errors

      const m = tag.opts.model
      return (
        m ?
        (m.errors || {})[tag.opts.fieldId] || [] :
        []
      )
    }
    tag.has_errors = () => tag.errors().length > 0

    tag.val = () => {
      const element = Zepto(tag.root).find('input, textarea, select')

      return (
        tag.inputType() == 'checkbox' ?
        element.prop('checked') :
        element.val()
      )
    }
  </script>
</kor-field>