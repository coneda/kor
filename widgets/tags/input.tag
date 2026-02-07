<kor-input class="{'has-errors': opts.errors}">
  <label if={opts.type != 'radio' && opts.type != 'submit' && opts.type != 'reset'}>
    <span show={!opts.hideLabel}>{opts.label}</span>
    <a
      if={opts.help}
      href="#"
      title={tcap('nouns.help')}
      onclick={toggleHelp}
    ><i class="fa fa-question-circle"></i></a>
    <input
      if={opts.type != 'select' && opts.type != 'textarea'}
      type={opts.type || 'text'}
      name={opts.name}
      value={valueFromParent()}
      checked={checkedFromParent()}
      placeholder={opts.placeholder}
      autocomplete={opts.autocomplete || (opts.wikidata ? 'off' : null)}
    />
    <textarea
      if={opts.type == 'textarea'}
      name={opts.name}
      value={valueFromParent()}
    ></textarea>
    <select
      if={opts.type == 'select'}
      name={opts.name}
      value={valueFromParent()}
      multiple={opts.multiple}
      disabled={opts.isDisabled}
    >
      <option if={opts.placeholder !== undefined} value={placeholderValue()}>{opts.placeholder}</option>
      <option
        each={item in opts.options}
        value={item.id || item.value || item}
        selected={selected(item)}
      >{item.name || item.label || item}</option>
    </select>
  </label>
  <input
    if={opts.type == 'submit'}
    type="submit"
    value={opts.label || tcap('verbs.save')}
  />
  <input
    if={opts.type == 'reset'}
    type="reset"
    value={opts.label || tcap('verbs.reset')}
  />
  <virtual if={opts.type == 'radio'}>
    <label>
      {opts.label}
      <a
        if={opts.help}
        href="#"
        title={tcap('nouns.help')}
        onclick={toggleHelp}
      ><i class="fa fa-question-circle"></i></a>
    </label>
    <label class="radio" each={item in opts.options}>
      <input
        type="radio"
        name={opts.name}
        value={item.id || item.value || item}
        checked={valueFromParent() == (item.id || item.value || item)}
      />
      <virtual if={!item.image_url}>{item.name || item.label || item}</virtual>
      <img if={item.image_url} src={item.image_url} />
    </label>
  </virtual>
  <div if={opts.help && showHelp} class="help" ref="help"></div>
  <div class="errors" if={opts.errors}>
    <div each={e in opts.errors}>
      {e}
    </div>
  </div>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // On mount, set focus and initialize Wikidata if applicable
  tag.on('mount', function() {
    if (tag.opts.autofocus) {
      Zepto(tag.root).find('input, textarea, select').focus();
    }
    if (tag.opts.wikidata) {
      wApp.wikidata.setup(tag);
    }
  });
  
  // Get the name of the input
  tag.name = function() {
    return tag.opts.name;
  };

  // Get the value of the input
  tag.value = function() {
    var result

    if (tag.opts.type === 'checkbox') {
      return Zepto(tag.root).find('input').prop('checked')
    }
    
    if (tag.opts.type === 'radio') {
      var inputs = Zepto(tag.root).find('input')
      for (var i = 0; i < inputs.length; i++) {
        var input = $(inputs[i])
        if (input.prop('checked')) {
          return input.attr('value')
        }
      }
    }
    
    if (tag.opts.type === 'submit') return null
    
    if (tag.opts.type === 'file') {
      var files = tag.input()[0].files
      if (files.length == 0) return null

      return files[0]
    }

    result = Zepto(tag.root).find('input, select, textarea').val()
    return result === "0" && tag.opts.type === 'select' ? undefined : result
  }

  // Get the value from the parent
  tag.valueFromParent = function() {
    return tag.opts.type === 'checkbox' ? 1 : tag.opts.riotValue;
  };

  // Get the checked state from the parent
  tag.checkedFromParent = function() {
    return tag.opts.type === 'checkbox' && tag.opts.riotValue;
  };

  // Check if the input is checked
  tag.checked = function() {
    return tag.opts.type === 'checkbox' &&
           Zepto(tag.root).find('input').prop('checked');
  };

  // Set the value of the input
  tag.set = function(value) {
    if (tag.opts.type === 'checkbox') {
      Zepto(tag.root).find('input').prop('checked', !!value);
    } else if (tag.opts.type === 'radio') {
      var inputs = Zepto(tag.root).find('input');
      for (var i = 0; i < inputs.length; i++) {
        var input = $(inputs[i]);
        input.prop('checked', input.attr('value') === value);
      }
    } else if (tag.opts.type === 'submit') {
      // Do nothing
    } else if (tag.opts.type === 'select' && Array.isArray(value)) {
      // we have to simulate a working Zepto.val([...])
      var select = Zepto(tag.root).find('select');
      select.val([]);
      value.forEach(function(v) {
        select.find("option[value='" + v + "']").prop('selected', true);
      });
    } else {
      Zepto(tag.root).find('input, select, textarea').val(value);
    }
  };

  // Reset the input to its parent value
  tag.reset = function() {
    tag.set(tag.valueFromParent());
  };

  // Check if an item is selected
  tag.selected = function(item) {
    var v = item.id || item.value || item;
    if (tag.opts.multiple) {
      return (tag.valueFromParent() || []).indexOf(v) > -1;
    } else {
      return String(v) === String(tag.valueFromParent());
    }
  };

  // Toggle help visibility
  tag.toggleHelp = function(event) {
    event.preventDefault();
    tag.showHelp = !tag.showHelp;
    tag.update();
    if (tag.showHelp) {
      Zepto(tag.refs.help).html(tag.opts.help);
    }
  };

  // Get the input element
  tag.input = function() {
    return Zepto(tag.root).find('input, select, textarea');
  };

  // Get the placeholder value
  tag.placeholderValue = function() {
    return tag.opts.placeholderValue === undefined ? 0 : tag.opts.placeholderValue;
  };
</script>
</kor-input>