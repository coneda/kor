<kor-datings-editor>
  <div class="header" if={add}>
    <button onclick={add} class="pull-right" type="button">
      {t('verbs.add', {capitalize: true})}
    </button>
    <label>{opts.label || tcap('activerecord.models.entity_dating', {count: 'other'})}</label>
    <div class="clearfix"></div>
  </div>

  <ul show={anyVisibleDatings()}>
    <li
      each={dating, i in data}
      show={!dating._destroy}
      visible={!dating._destroy}
      no-reorder
    >
      <kor-input
        label={t('activerecord.attributes.dating.label', {capitalize: true})}
        value={dating.label}
        ref="labels"
        errors={errorsFor(i, 'label')}
      />
      <kor-input
        label={t('activerecord.attributes.dating.dating_string', {capitalize: true})}
        value={dating.dating_string}
        ref="dating_strings"
        errors={errorsFor(i, 'dating_string')}
      />
      <div class="kor-text-right">
        <button onclick={remove}>
          {t('verbs.delete')}
        </button>
      </div>
      <div class="clearfix"></div>
    </li>
  </ul>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // On mount, initialize data and update the tag
  tag.on('mount', function() {
    tag.data = tag.opts.riotValue || [];
    tag.deleted = [];
    tag.update();
  });

  // Check if any visible datings exist
  tag.anyVisibleDatings = function() {
    for (var i = 0; i < (tag.data || []).length; i++) {
      var dating = tag.data[i];
      if (!dating['_destroy']) return true;
    }
    return false;
  };

  // Get the name of the tag
  tag.name = function() {
    return tag.opts.name;
  };

  // Get errors for a specific field
  tag.errorsFor = function(i, field) {
    var e = tag.opts.errors || [];
    var o = e[i] || {};
    return o[field];
  };

  // Set the data and update the tag
  tag.set = function(values) {
    tag.data = values;
    tag.update();

    for (var i = 0; i < tag.data.length; i++) {
      var dating = tag.data[i];
      tag.setDating(i, dating);
    }
  };

  // Add a new dating
  tag.add = function(event) {
    if (event) event.preventDefault();
    tag.data.push({ label: tag.opts.defaultDatingLabel });
    tag.update();
  };

  // Remove a dating
  tag.remove = function(event) {
    event.preventDefault();
    var dating = event.item.dating;
    var index = event.item.i;
    if (dating.id) {
      dating._destroy = true;
    } else {
      tag.data.splice(index, 1);
    }
  };

  // Get the value of all datings
  tag.value = function() {
    var labelInputs = wApp.utils.toArray(tag.refs['labels']);
    var datingStringInputs = wApp.utils.toArray(tag.refs['dating_strings']);

    for (var i = 0; i < tag.data.length; i++) {
      var dating = tag.data[i];
      dating['label'] = labelInputs[i].value();
      dating['dating_string'] = datingStringInputs[i].value();
    }

    return tag.data;
  };
</script>
</kor-datings-editor>