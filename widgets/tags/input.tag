<kor-input>

  <label>
    {opts.label}
    <input
      if={opts.type != 'select'}
      type={opts.type || 'text'}
      name={opts.name}
      placeholder={opts.placeholder || opts.label}
      value={value_from_parent()}
      checked={checked()}
    />
    <select
      if={opts.type == 'select'}
      name={opts.name}
      value={value_from_parent()}
    >
      <option if={opts.placeholder} value={0}>
        {opts.placeholder}
      </option>
      <option
        each={item in opts.options}
        value={item.id || item.value}
      >
        {item.name || item.label}
      </option>
    </select>
  </label>
  <ul class="kor-errors">
    <li each={e in opts.errors}>{e}</li>
  </ul>

  <script type="text/coffee">
    tag = this

    tag.value = ->
      if tag.opts.type == 'checkbox'
        Zepto(tag.root).find('input').prop('checked')
      else
        Zepto(tag.root).find('input, select').val()
    tag.value_from_parent = ->
      if tag.opts.type == 'checkbox' then 1 else tag.opts.value
    tag.checked = ->
      tag.opts.type == 'checkbox' && tag.opts.value
    tag.set = (value) ->
      if tag.opts.type == 'checkbox'
        Zepto(tag.root).find('input').prop('checked', !!value)
      else
        Zepto(tag.root).find('input, select').val(value)
    tag.reset = ->
      console.log tag.value_from_parent()
      tag.set tag.value_from_parent()
  </script>

</kor-input>