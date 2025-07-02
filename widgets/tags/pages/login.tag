<kor-login>
  <kor-help-button key="login" />

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('verbs.login')}</h1>

      <div if={federationAuth()}>
        <div class="hr"></div>
        <p>{t('prompt.federation_login')}</p>

        <a href="/env_auth" class="kor-button">
          {config()['env_auth_button_label']}
        </a>

        <div class="hr"></div>
      </div>

      <virtual if={localLabel()}>
        <p>{t('prompt.local_login')}</p>
        <a
          href="#"
          class="kor-local-button"
          onclick={toggleLocal}
        >{localLabel()}</a>
      </virtual>

      <virtual if={!localLabel() || localActive}>
        <form
          class="form"
          method="POST"
          action='#/login'
          onsubmit={submit}
        >
          <kor-input
            label={tcap('activerecord.attributes.user.name')}
            type="text"
            ref="username"
          />

          <kor-input
            label={tcap('activerecord.attributes.user.password')}
            type="password"
            ref="password"
          />

          <kor-input
            type="submit"
            label={tcap('verbs.login')}
          />
        </form>

        <a href="#/password-recovery" class="password-recovery">
          {tcap('password_forgotten_question')}
        </a>
      </virtual>

      <div class="hr"></div>

      <kor-login-info />
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <div class="kor-content-box">
      <div class="kor-blend"></div>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.info);
  tag.mixin(wApp.mixins.config);
  tag.mixin(wApp.mixins.page);

  // Focus the first input on mount
  tag.on('mount', function() {
    Zepto(tag.root).find('input').first().focus();
  });

  // Handle login form submission
  tag.submit = function(event) {
    event.preventDefault();
    var username = tag.refs.username.value();
    var password = tag.refs.password.value();
    wApp.auth.login(username, password).then(function() {
      var r = wApp.routing.query()['return_to'];
      if (r) {
        window.location.hash = decodeURIComponent(r);
      } else {
        wApp.routing.path('/search');
      }
    });
  };

  // Toggle local login form visibility
  tag.toggleLocal = function(event) {
    event.preventDefault();
    tag.localActive = !tag.localActive;
  };

  // Check if federation auth is available
  tag.federationAuth = function() {
    var l = tag.config().env_auth_button_label;
    return typeof l === 'string' && l.length > 0;
  };

  // Get the local login button label, or null if not set
  tag.localLabel = function() {
    var l = tag.config().env_auth_local_button_label;
    if (typeof l === 'string' && l.length > 0) {
      return l;
    } else {
      return null;
    }
  };
</script>
</kor-login>
