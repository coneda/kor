<kor-field-editor>

  <h2 if={opts.id}>
    {tcap('objects.edit', {interpolations: {o: 'activerecord.models.field'}})}
  </h2>
  <h2 if={!opts.id}>
    {tcap('objects.create', {interpolations: {o: 'activerecord.models.field'}})}
  </h2>

  <form if={data && types} onsubmit={submit}>
    <kor-input
      name="type"
      label={tcap('activerecord.attributes.field.type')}
      type="select"
      options={types_for_select}
      value={data.type}
      is-disabled={data.id}
      ref="fields"
      onchange={updateSpecialFields}
    />

    <virtual each={f in specialFields}>
      <kor-input
        name={f.name}
        label={tcap('activerecord.attributes.field.' + f.name)}
        type={f.type}
        options={f.options}
        value={data[f.name]}
        errors={errors[f.name]}
        ref="fields"
      />
    </virtual>

    <kor-input
      name="name"
      label={tcap('activerecord.attributes.field.name')}
      value={data.name}
      errors={errors.name}
      ref="fields"
    />

    <kor-input
      name="show_label"
      label={tcap('activerecord.attributes.field.show_label')}
      value={data.show_label}
      errors={errors.show_label}
      ref="fields"
    />

    <kor-input
      name="form_label"
      label={tcap('activerecord.attributes.field.form_label')}
      value={data.form_label}
      errors={errors.form_label}
      ref="fields"
    />

    <kor-input
      name="search_label"
      label={tcap('activerecord.attributes.field.search_label')}
      value={data.search_label}
      errors={errors.search_label}
      ref="fields"
    />

    <kor-input
      name="help_text"
      type="textarea"
      label={tcap('activerecord.attributes.field.help_text')}
      value={data.help_text}
      errors={errors.help_text}
      ref="fields"
    />

    <kor-input
      name="mandatory"
      type="checkbox"
      label={tcap('activerecord.attributes.field.mandatory')}
      value={data.mandatory}
      ref="fields"
    />

    <kor-input
      name="show_on_entity"
      type="checkbox"
      label={tcap('activerecord.attributes.field.show_on_entity')}
      value={data.show_on_entity}
      ref="fields"
    />

    <kor-input
      name="is_identifier"
      type="checkbox"
      label={tcap('activerecord.attributes.field.is_identifier')}
      value={data.is_identifier}
      ref="fields"
    />

    <div class="hr"></div>

    <kor-input type="submit" />
  </form>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.errors = {};

  // On mount, fetch field data if editing, otherwise initialize, then fetch types
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch();
    } else {
      tag.data = { type: 'Fields::String' };
      tag.update();
    }
    fetchTypes();
  });

  // Update special fields when type changes
  tag.updateSpecialFields = function(event) {
    var typeName = event ? Zepto(event.target).val() : tag.data.type;
    tag.data.type = typeName;
    var types = tag.types;
    if (types) {
      tag.specialFields = types[typeName].fields;
      tag.update();
    }
  };

  // Handle form submission for create or update
  tag.submit = function(event) {
    event.preventDefault();
    var p = tag.opts.id ? update() : create();
    p.done(function(data) {
      tag.errors = {};
      tag.opts.notify.trigger('refresh');
      route("/kinds/" + tag.opts.kindId + "/edit");
    });
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors;
      wApp.utils.scrollToTop();
    });
    p.always(function() {
      tag.update();
    });
  };

  // Create a new field
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: "/kinds/" + tag.opts.kindId + "/fields",
      data: JSON.stringify(values())
    });
  };

  // Update an existing field
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: "/kinds/" + tag.opts.kindId + "/fields/" + tag.opts.id,
      data: JSON.stringify(values())
    });
  };

  // Collect form values for submission
  var values = function() {
    var results = {};
    for (var k in tag.refs.fields) {
      if (Object.prototype.hasOwnProperty.call(tag.refs.fields, k)) {
        var t = tag.refs.fields[k];
        results[t.name()] = t.value();
      }
    }
    return {
      field: results,
      klass: results.type
    };
  };

  // Fetch field data from server
  var fetch = function() {
    Zepto.ajax({
      url: "/kinds/" + tag.opts.kindId + "/fields/" + tag.opts.id,
      success: function(data) {
        tag.data = data;
        tag.update();
        tag.updateSpecialFields();
      }
    });
  };

  // Fetch available field types from server
  var fetchTypes = function() {
    Zepto.ajax({
      url: "/fields/types",
      success: function(data) {
        tag.types = {};
        tag.types_for_select = [];
        for (var i = 0; i < data.length; i++) {
          var t = data[i];
          tag.types_for_select.push({ value: t.name, label: t.label });
          tag.types[t.name] = t;
        }
        tag.update();
        tag.updateSpecialFields();
      }
    });
  };
</script>

</kor-field-editor>