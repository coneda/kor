<kor-entity-properties-editor>
  <kor-input
    label={opts.label}
    type="textarea"
    ref="field"
  />

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.name = function() {
      return tag.opts.name;
    }

    tag.set = function(values) {
      var results = [];
      if (values) {
        for (var i = 0; i < values.length; i++) {
          var v = values[i];
          results.push(v.label + ': ' + v.value);
        }
      }
      tag.refs['field'].set(results.join("\n"));
    }

    tag.value = function() {
      var text = tag.refs['field'].value()
      if (text.match(/^\s*$/)) {return []}

      var results = [];
      var lines = text.split("\n");
      for (var i = 0; i < lines.length; i++) {
        var kv = lines[i].split(/\s*:\s*/);
        results.push({'label': kv.shift(), 'value': kv.join(':')})
      }
      return results;
    }
  </script>
</kor-entity-properties-editor>