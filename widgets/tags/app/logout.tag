<kor-logout show={isLoggedIn()}>
  <a href="#" onclick={logout}>
    {t('verbs.logout')}
  </a>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.logout = (event) ->
      event.preventDefault()
      wApp.auth.logout().then ->
        wApp.bus.trigger 'logout'
        wApp.bus.trigger 'routing:path', wApp.routing.parts()
  </script>
</kor-logout>