<kor-user-editor>
  <div class="kor-layout-left kor-layout-large" show={loaded}>
    <div class="kor-content-box">
      <h1 show={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.user'}})}
      </h1>
      <h1 show={!opts.id}>
        {tcap('objects.new', {interpolations: {o: 'activerecord.models.user'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          name="lock_version"
          value={data.lock_version || 0}
          ref="fields"
          type="hidden"
        />

        <kor-input
          label={tcap('activerecord.attributes.user.personal')}
          name="make_personal"
          type="checkbox"
          ref="fields"
          value={data.personal}
          errors={errors.make_personal}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.full_name')}
          name="full_name"
          ref="fields"
          value={data.full_name}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.plain_password')}
          placeholder={tcap('prompts.password')}
          name="plain_password"
          type="password"
          ref="fields"
          errors={errors.plain_password}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.plain_password_confirmation')}
          placeholder={tcap('prompts.password')}
          name="plain_password_confirmation"
          type="password"
          ref="fields"
          errors={errors.plain_password_confirmation}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.email')}
          name="email"
          ref="fields"
          value={data.email}
          errors={errors.email}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.api_key')}
          name="api_key"
          type="textarea"
          ref="fields"
          value={data.api_key}
          errors={errors.api_key}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.active')}
          name="active"
          type="checkbox"
          ref="fields"
          value={data.active}
        />

        <div class="expires-at">
          <kor-input
            label={tcap('activerecord.attributes.user.expires_at')}
            name="expires_at"
            type="date"
            ref="fields"
            value={valueForDate(data.expires_at)}
            errors={errors.expires_at}
          />

          <button onclick={expiresIn(0)}>
            {tcap('activerecord.attributes.user.does_not_expire')}
          </button>
          <button onclick={expiresIn(7)}>
            {tcap('activerecord.attributes.user.expires_in_days', {interpolations: {amount: 7}})}
          </button>
          <button onclick={expiresIn(30)}>
            {tcap('activerecord.attributes.user.expires_in_days', {interpolations: {amount: 30}})}
          </button>
          <button onclick={expiresIn(180)}>
            {tcap('activerecord.attributes.user.expires_in_days', {interpolations: {amount: 180}})}
          </button>

          <div class="clearfix"></div>
        </div>

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.parent_username')}
          name="parent_username"
          type="text"
          ref="fields"
          value={data.parent_username}
          errors={errors.parent_username}
        />

        <div class="hr"></div>

        <kor-input
          if={credentials}
          label={tcap('activerecord.attributes.user.groups')}
          name="group_ids"
          type="select"
          options={credentials.records}
          multiple={true}
          ref="fields"
          value={data.group_ids}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.authority_group_admin')}
          name="authority_group_admin"
          type="checkbox"
          ref="fields"
          value={data.authority_group_admin}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.relation_admin')}
          name="relation_admin"
          type="checkbox"
          ref="fields"
          value={data.relation_admin}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.kind_admin')}
          name="kind_admin"
          type="checkbox"
          ref="fields"
          value={data.kind_admin}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.admin')}
          name="admin"
          type="checkbox"
          ref="fields"
          value={data.admin}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.notify')}
          name="notify"
          type="checkbox"
          ref="notify"
          value={data.admin}
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
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.page);

  // On mount, initialize errors and fetch data if admin
  tag.on('mount', function() {
    tag.errors = {};

    if (tag.isAdmin()) {
      Zepto.when(fetchCredentials(), fetchUser()).then(function() {
        tag.loaded = true;
        tag.update();
      });
    } else {
      wApp.bus.trigger('access-denied');
    }
  });

  // Handle form submission
  tag.submit = function(event) {
    event.preventDefault();
    var p = tag.opts.id ? update() : create();
    p.done(function(data) {
      wApp.routing.path('/users');
    });
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors;
      wApp.utils.scrollToTop();
    });
    p.always(function() {
      tag.update();
    });
  };

  // TODO: this needs to be done entirely on the server. The client should
  // just tranfer the amount of days to add

  // Set expiration date
  tag.expiresIn = function(days) {
    return function(event) {
      event.preventDefault();

      if (days) {
        var date = new Date();
        date = new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
        expiresAtTag().set([
          date.getUTCFullYear(),
          ('00' + (date.getUTCMonth() + 1)).slice(-2),
          ('00' + date.getUTCDate()).slice(-2)
        ].join('-'));
      } else {
        expiresAtTag().set(undefined);
      }
    };
  };

  // Format date value
  tag.valueForDate = function(date) {
    return date ? strftime('%Y-%m-%d', new Date(date)) : '';
  };

  // Fetch credentials
  function fetchCredentials() {
    return Zepto.ajax({
      url: '/credentials',
      success: function(data) {
        tag.credentials = data;
        tag.update();
      }
    });
  }

  // Fetch user data
  var fetchUser = function() {
    if (tag.opts.id) {
      return Zepto.ajax({
        url: "/users/" + tag.opts.id,
        data: { include: 'all' },
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      });
    } else {
      tag.data = { lock_version: 0 };
      tag.update();
    }
  }

  // Create a new user
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: "/users",
      data: JSON.stringify({
        user: values(),
        notify: tag.refs.notify.value()
      })
    });
  }

  // Update an existing user
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: "/users/" + tag.opts.id,
      data: JSON.stringify({ user: values() })
    });
  }

  // Get the expires_at field tag
  var expiresAtTag = function() {
    for (var i = 0; i < tag.refs.fields.length; i++) {
      var f = tag.refs.fields[i];
      if (f.name() === 'expires_at') {
        return f;
      }
    }
    return undefined;
  }

  // Collect values from input fields
  var values = function() {
    var results = {};
    for (var i = 0; i < tag.refs.fields.length; i++) {
      var f = tag.refs.fields[i];
      results[f.name()] = f.value();
    }
    return results;
  }
</script>
</kor-user-editor>
