<kor-header>

  <a href={rootPath()} class="logo">
    <img src="images/logo.gif" />
  </a>

  <div class="session">
    <span>
      <strong>ConedaKOR</strong>
      {t('nouns.version')}
      {info().version}
    </span>

    <img src="images/vertical_dots.gif" />

    <span>{t('logged_in_as')}:</span>  
    <strong>{currentUser().display_name}</strong>

    <img src="images/vertical_dots.gif" />

    <kor-logout />
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.info)
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
  </script>

</kor-header>