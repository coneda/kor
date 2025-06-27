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

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.page);

  // Returns the current routing fragment, URL-encoded
  tag.returnTo = function() {
    return encodeURIComponent(wApp.routing.fragment());
  };

  // Handles the "back" action by triggering a go-back event
  tag.back = function(event) {
    event.preventDefault();
    wApp.bus.trigger('go-back');
  };
</script>
</kor-access-denied>