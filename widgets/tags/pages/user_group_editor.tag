<kor-user-group-editor>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.user_group'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.user_group'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.user_group.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

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

  // Initialize errors and data before mounting the tag
  tag.on('before-mount', function() {
    tag.errors = {};
    tag.data = {};
  });

  // On mount, fetch data if editing an existing user group
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch();
    }
  });

  // Handle form submission for creating or updating a user group
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

  // Fetch user group data from the server
  function fetch() {
    Zepto.ajax({
      url: '/user_groups/' + tag.opts.id,
      success: function(data) {
        tag.data = data;
        tag.update();
      }
    });
  }

  // Create a new user group
  function create() {
    return Zepto.ajax({
      type: 'POST',
      url: '/user_groups',
      data: JSON.stringify({ user_group: values() })
    });
  }

  // Update an existing user group
  function update() {
    return Zepto.ajax({
      type: 'PATCH',
      url: '/user_groups/' + tag.opts.id,
      data: JSON.stringify({ user_group: values() })
    });
  }

  // Collect form values for submission
  function values() {
    return { name: tag.refs.fields.value() };
  }
</script>
</kor-user-group-editor>
