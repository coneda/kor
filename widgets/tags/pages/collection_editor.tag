<kor-collection-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.collection'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.collection'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.collection.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <virtual if={credentials}>
          <div class="hr"></div>

          <kor-input
            each={policy in policies}
            label={tcap('activerecord.attributes.collection.' + policy)}
            name={policy}
            type="select"
            multiple={true}
            options={credentials.records}
            value={data.permissions[policy]}
            ref="permissions"
          />
        </virtual>

        <div class="hr"></div>

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.page);

  // List of available policies
  tag.policies = [
    'view', 'edit', 'create', 'delete', 'download_originals', 'tagging',
    'view_meta'
  ];

  // Initialize errors before mounting
  tag.on('before-mount', function() {
    tag.errors = {};
  });

  // On mount, fetch collection data if editing, otherwise initialize data, and fetch credentials
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch();
    } else {
      tag.data = {};
    }
    fetchCredentials();
  });

  // Handle form submission for create or update
  tag.submit = function(event) {
    event.preventDefault();
    var p = tag.opts.id ? update() : create();
    p.done(function(data) {
      tag.errors = {};
      window.history.back();
    });
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors;
      wApp.utils.scrollToTop();
    });
    p.always(function() {
      tag.update();
    });
  };

  // Fetch collection data from server
  var fetch = function() {
    Zepto.ajax({
      url: '/collections/' + tag.opts.id,
      data: { include: 'permissions' },
      success: function(data) {
        tag.data = data;
        tag.update();
      }
    });
  };

  // Create a new collection
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: '/collections',
      data: JSON.stringify({ collection: values() })
    });
  };

  // Update an existing collection
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: '/collections/' + tag.opts.id,
      data: JSON.stringify({ collection: values() })
    });
  };

  // Collect form values for submission
  var values = function() {
    var results = {
      name: tag.refs.fields.value(),
      permissions: {}
    };
    for (var i = 0; i < tag.refs.permissions.length; i++) {
      var f = tag.refs.permissions[i];
      if (!results.permissions[f.name()]) {
        results.permissions[f.name()] = f.value();
      }
    }
    return results;
  };

  // Fetch credentials for select options
  var fetchCredentials = function() {
    Zepto.ajax({
      url: '/credentials',
      success: function(data) {
        tag.credentials = data;
        tag.update();
      }
    });
  };
</script>
</kor-collection-editor>