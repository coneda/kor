<kor-header>

  <a href="#/" class="logo">
    <img src="images/logo.gif" />
  </a>

  <div class="session">
    <span>
      <strong>ConedaKOR</strong>
      {t('nouns.version')}
      {info().version}
    </span>

    <span if={currentUser()}>
      <img src="images/vertical_dots.gif" />
      {t('logged_in_as')}:
      <strong>{currentUser().display_name}</strong>

      <span if={!isGuest()}>
        <img src="images/vertical_dots.gif" />
        <kor-logout />
      </span>
    </span>

  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    tag = this;
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
  </script>

</kor-header>