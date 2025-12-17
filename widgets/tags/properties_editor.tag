<kor-properties-editor>

  <div class="header">
    <button onclick={add} class="pull-right">
      {t('verbs.add', {capitalize: true})}
    </button>
    <label>
      {t(
        'activerecord.attributes.relationship.property.other',
        {capitalize: true}
      )}
    </label>
    <div class="clearfix"></div>
  </div>

  <ul>
    <li each={property, i in properties}>
      <kor-input
        name="value"
        value={property.value}
        ref="inputs"
      />
      <div class="kor-text-right">
        <button onclick={remove(i)}>
          {t('verbs.remove')}
        </button>
      </div>
    </li>
  </ul>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // On mount, initialize properties from options
  tag.on('mount', function() {
    tag.properties = [];
    if (tag.opts.properties) {
      for (var i = 0; i < tag.opts.properties.length; i++) {
        var p = tag.opts.properties[i];
        tag.properties.push({ value: p });
      }
    }
  });

  // Add a new empty property
  tag.add = function(event) {
    event.preventDefault();
    tag.properties.push({ value: "" });
    tag.update();
  };

  // Remove a property at the given index
  tag.remove = function(index) {
    return function(event) {
      event.preventDefault();
      tag.properties.splice(index, 1);
      tag.update();
    };
  };

  // Get all property values from input refs
  tag.value = function() {
    var inputs = wApp.utils.toArray(tag.refs.inputs);
    return inputs.map(function(e) { return e.value(); });
  };
</script>
</kor-properties-editor>