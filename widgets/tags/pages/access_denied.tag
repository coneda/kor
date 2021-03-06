<kor-access-denied>
  <div class="kor-layout-left kor-layout-large kor-clear-after">
    <div class="kor-content-box">
      <h1>{tcap('access_denied')}</h1>

      {t('messages.access_denied')}

      <div class="hr"></div>

      <a href="#/login?return_to={returnTo()}">{t('verbs.login')}</a> |
      <a href="#" onclick={back}>{t('back')}</a>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.page)

    tag.returnTo = -> encodeURIComponent(wApp.routing.fragment())
    tag.back = (event) ->
      event.preventDefault()
      wApp.bus.trigger 'go-back'
  </script>
</kor-access-denied>