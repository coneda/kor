<kor-dataset-fields>
  <virtual each={field in opts.fields}>
    <kor-input
      if={simple(field)}
      name={field.name}
      label={field.form_label}
      riot-value={values()[field.name]}
      ref="fields"
      errors={errorsFor(field)}
    />

    <kor-input
      if={field.type == 'Fields::Text'}
      name={field.name}
      label={field.form_label}
      riot-value={values()[field.name]}
      ref="fields"
      errors={errorsFor(field)}
      type="textarea"
    />

    <kor-input
      if={field.type == 'Fields::Select'}
      name={field.name}
      label={field.form_label}
      riot-value={values()[field.name]}
      ref="fields"
      errors={errorsFor(field)}
      type="select"
      options={field.values.split("\n")}
      multiple={field.subtype == 'multiselect'}
    />
  </virtual>

  <script type="text/javascript">
    var tag = this;

    tag.errorsFor = function(field) {
      if (tag.opts.errors) {
        return tag.opts.errors[field.name];
      }
    }

    tag.values = function() {
      return opts.values || {};
    }

    tag.set = function(values) {
      var fields = wApp.utils.toArray(tag.refs['fields'])

      for (var i = 0; i < fields.length; i++) {
        var f = fields[i];
        f.set(values[f.name()]);
      }
    }

    tag.name = function() {return tag.opts.name;}

    tag.value = function() {
      var result = {};
      var inputs = wApp.utils.toArray(tag.tags['kor-input'])
      for (var i = 0; i < inputs.length; i++) {
        var field = inputs[i];
        result[field.name()] = field.value();
      }
      return result;
    }

    tag.type = function(field) {
      if (field.type == 'Fields::Text') {return 'textarea'}
      return 'text';
    }

    tag.simple = function(field) {
      return(
        field.type == 'Fields::String' ||
        field.type == 'Fields::Isbn' ||
        field.type == 'Fields::Regex'
      )
    }

    tag.inputByName = function(name) {
      var inputs = wApp.utils.toArray(tag.tags['kor-input']);
      for (var i = 0; i < inputs.length; i++) {
        var field = inputs[i];
        if (field.name() === name) {
          return field;
        }
      }
      return null;
    }
  </script>
</kor-dataset-fields>