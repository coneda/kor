<kor-dataset-fields>
  <kor-input
    each={field in opts.fields}
    name={field.name}
    label={field.form_label}
    riot-value={values()[field.name]}
    ref="fields"
    errors={errorsFor(field)}
  />

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

    tag.name = function() {return tag.opts.name;}

    tag.value = function() {
      var result = {};
      var inputs = tag.tags['kor-input'] || []
      for (var i = 0; i < inputs.length; i++) {
        var field = tag.tags['kor-input'][i];
        result[field.name()] = field.value();
      }
      return result;
    }
  </script>
</kor-dataset-fields>