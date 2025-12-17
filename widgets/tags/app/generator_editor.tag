<kor-generator-editor>

  <h2 if={opts.id}>
    {tcap('objects.edit', {interpolations: {o: 'activerecord.models.generator'}})}
  </h2>
  <h2 if={!opts.id}>
    {tcap('objects.create', {interpolations: {o: 'activerecord.models.generator'}})}
  </h2>

  <form if={data} onsubmit={submit}>
    <kor-input
      name="name"
      label={tcap('activerecord.attributes.generator.name')}
      riot-value={data.name}
      errors={errors.name}
      ref="fields"
    />

    <kor-input
      name="directive"
      label={tcap('activerecord.attributes.generator.directive')}
      help={tcap('help.generator_directive')}
      type="textarea"
      riot-value={data.directive}
      errors={errors.directive}
      ref="fields"
    />

    <div class="hr"></div>

    <kor-input type="submit" />
  </form>


 <script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.errors = {};

  // On mount, fetch generator data if editing, otherwise initialize
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch();
    } else {
      tag.data = {};
      tag.update();
    }
  });

  // Handle form submission for create or update
  tag.submit = function(event) {
    event.preventDefault();
    var p = tag.opts.id ? update() : create();
    p.then(function(response) {
      tag.errors = {};
      tag.opts.notify.trigger('refresh');
      route("/kinds/" + tag.opts.kindId + "/edit");
    });
    p.catch(function(response) {
      tag.errors = response.data.errors;
      wApp.utils.scrollToTop();
    });
    p.finally(function() {
      tag.update();
    });
  };

  // Create a new generator
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: "/kinds/" + tag.opts.kindId + "/generators",
      data: JSON.stringify(values())
    });
  };

  // Update an existing generator
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: "/kinds/" + tag.opts.kindId + "/generators/" + tag.opts.id,
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
    return { generator: results };
  };

  // Fetch generator data from server
  var fetch = function() {
    Zepto.ajax({
      url: "/kinds/" + tag.opts.kindId + "/generators/" + tag.opts.id,
      success: function(data) {
        tag.data = data;
        tag.update();
      }
    });
  };
</script>
</kor-generator-editor>

