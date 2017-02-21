<kor-login>

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>Login</h1>

      <form class="form" method="POST" action='#/login' onsubmit={submit}>
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
          value={tcap('verbs.login')}
        />

        <a href="#/password_recovery">{tcap('password_forgotten')}</a>

        <div class="hr"></div>

        <strong>
          <span class="kor-shine">ConedaKOR</span>
          {t('nouns.version')}
          <span class="kor-shine">{info().version}</span>
        </strong>

        <div class="hr silent"></div>

        <strong>
          {tcap('provided_by')}
          <span class="kor-shine">{info().operator}</span>
        </strong>

        <div class="hr silent"></div>

        <strong>
          {tcap('nouns.license')}<br />
          <a href="http://www.gnu.org/licenses/agpl-3.0.txt" target="_blank">
            {t('nouns.agpl')}
          </a>
        </strong>

        <div class="hr silent"></div>

        <strong>
          »
          <a href={info().source_code_url} target="_blank">
            {t('objects.download', {interpolations: {o: 'nouns.source_code'}})}
          </a>
        </strong>
      </form>
    </div>
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.info)

    tag.submit = (event) ->
      event.preventDefault()
      username = tag.refs.username.value()
      password = tag.refs.password.value()
      wApp.auth.login(username, password).then ->
        wApp.bus.trigger 'routing:path', wApp.routing.parts()

  </script>
</kor-login>