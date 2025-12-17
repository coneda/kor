<kor-header>
  <a href="#/" class="logo">
    <kor-logo />
  </a>

  <div class="session">
    <kor-loading />
    
    <span>
      <strong>ConedaKOR</strong>
      <span if={isStatic()}>(static mode)</span>
      {t('nouns.version')}
      {info().version}
    </span>

    <span if={currentUser() && !isStatic()}>
      <img src="images/vertical_dots.gif" />
      {t('logged_in_as')}:
      <strong>{currentUser().display_name}</strong>
      <a
        href="#/profile"
        title={tcap('edit_self')}
      ><i class="fa fa-wrench"></i></a>

      <span if={!isGuest()}>
        <img src="images/vertical_dots.gif" />
        <kor-logout />
      </span>
    </span>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    let tag = this;
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
  </script>
</kor-header>