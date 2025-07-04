<kor-profile>
  <kor-help-button key="profile" />

  <div class="kor-layout-left kor-layout-large" show={loaded}>
    <div class="kor-content-box">
      <h1>{tcap('objects.edit', {interpolations: {o: 'nouns.profile'}})}</h1>

      <form onsubmit={submit} if={data}>
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
          label={tcap('activerecord.attributes.user.email')}
          name="email"
          ref="fields"
          value={data.email}
          errors={errors.email}
        />

        <div class="hr"></div>

        <virtual if={isFederationAuth()}>
          {tcap('messages.federation_password_reset_facility')}
          {tcap('please')}
          <a href={passwordResetUrl()}>
            {t('messages.federation_password_reset_prompt')}
          </a>
        </virtual>

        <virtual if={!isFederationAuth()}>
          <kor-input
            label={tcap('activerecord.attributes.user.plain_password')}
            name="plain_password"
            autocomplete="new-password"
            type="password"
            ref="fields"
            errors={errors.plain_password}
          />

          <kor-input
            label={tcap('activerecord.attributes.user.plain_password_confirmation')}
            name="plain_password_confirmation"
            type="password"
            autocomplete="new-password"
            ref="fields"
            errors={errors.plain_password_confirmation}
          />
        </virtual>

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
          label={tcap('activerecord.attributes.user.locale')}
          name="locale"
          type="select"
          options={['de', 'en']}
          ref="fields"
          value={data.locale}
        />

        <div class="hr"></div>

        <kor-input
          if={collections}
          label={tcap('activerecord.attributes.user.default_collection_id')}
          name="default_collection_id"
          type="select"
          options={collections.records}
          ref="fields"
          value={data.default_collection_id}
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

  // On mount, set title and fetch user and collections data
  tag.on('mount', function() {
    tag.title(tag.t('objects.edit', { interpolations: { o: 'nouns.profile' } }));
    tag.errors = {};

    if (tag.currentUser() && !tag.isGuest()) {
      Zepto.when(fetchCollections(), fetchUser()).then(function() {
        tag.loaded = true;
        tag.update();
      });
    } else {
      wApp.bus.trigger('access-denied');
    }
  });

  // Handle form submission for updating profile
  tag.submit = function(event) {
    event.preventDefault();
    var p = update();
    p.done(function(data) {
      tag.errors = {};
      window.history.back();
      wApp.bus.trigger('reload-session');
    });
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors;
      wApp.utils.scrollToTop();
    });
    p.always(function() {
      tag.update();
    });
  };

  // Set expiration date for the profile
  tag.expiresIn = function(days) {
    return function(event) {
      if (days) {
        var date = new Date();
        date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
        expiresAtTag().set(strftime('%Y-%m-%d', date));
      } else {
        expiresAtTag().set(undefined);
      }
    };
  };

  // Format date value
  tag.valueForDate = function(date) {
    return date ? strftime('%Y-%m-%d', new Date(date)) : '';
  };

  // Check if federation authentication is enabled
  tag.isFederationAuth = function() {
    return !!wApp.session.current.auth_source;
  };

  // Get password reset URL for federation authentication
  tag.passwordResetUrl = function() {
    return wApp.session.current.auth_source.password_reset_url;
  };

  // Fetch user data from server
  function fetchUser() {
    return Zepto.ajax({
      url: '/users/me',
      data: { include: 'security' },
      success: function(data) {
        tag.data = data;
        tag.update();
      }
    });
  }

  // Fetch collections data from server
  function fetchCollections() {
    return Zepto.ajax({
      url: '/collections',
      success: function(data) {
        tag.collections = data;
        tag.update();
      }
    });
  }

  // Update user profile data
  function update() {
    return Zepto.ajax({
      type: 'PATCH',
      url: '/users/me',
      data: JSON.stringify({
        id: tag.currentUser().id,
        user: values()
      })
    });
  }

  // Get the expiration date field
  function expiresAtTag() {
    for (var i = 0; i < tag.refs.fields.length; i++) {
      var f = tag.refs.fields[i];
      if (f.name() === 'expires_at') {
        return f;
      }
    }
    return undefined;
  }

  // Collect form values for submission
  function values() {
    var results = {};
    for (var i = 0; i < tag.refs.fields.length; i++) {
      var f = tag.refs.fields[i];
      results[f.name()] = f.value();
    }
    return results;
  }
</script>

</kor-profile>