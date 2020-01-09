<kor-synonyms-editor>
  <kor-input
    label={opts.label}
    type="textarea"
    ref="field"
    value={valueFromParent()}
  />

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.valueFromParent = function() {
      return opts.riotValue.join("\n");
    }

    tag.name = function() {return tag.opts.name}

    tag.set = function(value) {
      if (value) {
        tag.refs['field'].set(value.join("\n"));
      }
    }

    tag.value = function() {
      var text = tag.tags['kor-input'].value();
      if (text.match(/^\s*$/)) {return []}

      var lines = text.split("\n");
      return lines.filter(function(e) {return !!e});
    }
  </script>
</kor-synonyms-editor>