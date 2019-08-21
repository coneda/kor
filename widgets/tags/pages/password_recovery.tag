<kor-password-recovery>

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('password_reset')}</h1>

      <form onsubmit={submit}>
        <kor-input
          label={tcap('prompt.email_for_personal_password_reset')}
          name="email"
          type="text"
          ref="fields"
        />

        <div class="kor-text-right">
          <kor-input
            type="submit"
            label={tcap('verbs.reset')}
          />
        </div>
      </form>

      <hr />

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
    tag.mixin(wApp.mixins.page);

    tag.submit = function(event) {
      event.preventDefault();

      var params = {email: tag.refs.fields.value()};
      var promise = Zepto.ajax({
        type: 'POST',
        url: '/account-recovery',
        data: JSON.stringify(params),
        success: function(data) {
          wApp.routing.path('/login');
        }
      })
    }
  </script>
</kor-password-recovery>