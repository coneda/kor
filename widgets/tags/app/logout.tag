<kor-logout show={isLoggedIn()}>
  <a href="#" onclick={logout}>
    {t('verbs.logout')}
  </a>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // Logout handler
  tag.logout = function(event) {
    event.preventDefault();
    wApp.auth.logout().then(function() {
      wApp.bus.trigger('logout');
      wApp.bus.trigger('routing:path', wApp.routing.parts());
    });
  };
</script>
</kor-logout>