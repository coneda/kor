<kor-entity-properties-editor>
  <kor-input
    label={opts.label}
    type="textarea"
    value={valueFromParent()}
    help={tcap('help.property_input')}
    errors={opts.errors}
  />

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // Get value from parent and format it as a string
  tag.valueFromParent = function() {
    var results = [];
    if (tag.opts.riotValue) {
      tag.opts.riotValue.forEach(function(p) {
        results.push(p.label + ": " + p.value);
      });
    }
    return results.join("\n");
  };

  // Get the name of the tag
  tag.name = function() {
    return tag.opts.name;
  };

  // Get the value from the input and parse it into an array of objects
  tag.value = function() {
    var text = tag.tags['kor-input'].value();
    if (text.match(/^\s*$/)) {
      return [];
    }

    var results = [];
    text.split(/\n/).forEach(function(line) {
      if (!line.match(/^\s*$/)) {
        var kv = line.split(/:/);
        results.push({
          label: kv.shift().trim(),
          value: kv.join(':').trim()
        });
      }
    });
    return results;
  };
</script>
</kor-entity-properties-editor>