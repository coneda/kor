<kor-header>

  <span>{t('logged_in_as')}:</span>  
  <strong>{currentUser().display_name}</strong>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
  </script>

</kor-header>