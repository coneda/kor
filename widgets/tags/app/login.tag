<kor-login>

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>Login</h1>

      <div if={anyFederatedAuth()}>
        <div class="hr"></div>
        <p>{t('prompt.federation_login')}</p>

        <a href="/env_auth" class="kor-button">
          {config()['auth']['env_auth_button_label']}
        </a>

        <div class="hr"></div>
      </div>

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
      </form>

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
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <div class="kor-content-box">
      <div class="kor-blend"></div>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.info)
    tag.mixin(wApp.mixins.config)

    tag.on 'mount', ->
      Zepto(tag.root).find('input').first().focus()

    tag.submit = (event) ->
      event.preventDefault()
      username = tag.refs.username.value()
      password = tag.refs.password.value()
      wApp.auth.login(username, password).then ->
        parts = wApp.routing.parts()
        if r = parts.hash_query.return_to
          window.location.hash = decodeURIComponent(r)
        else
          wApp.bus.trigger 'routing:path', wApp.routing.parts()

    tag.anyFederatedAuth = ->
      for k, source of tag.config().auth.sources
        return true if source.type == 'env'
      false

  </script>
</kor-login>