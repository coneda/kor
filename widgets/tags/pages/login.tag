<kor-login>
  <kor-help-button key="login" />

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('verbs.login')}</h1>

      <div if={federationAuth()}>
        <div class="hr"></div>
        <p>{t('prompt.federation_login')}</p>

        <a href="/env_auth" class="kor-button">
          {config()['env_auth_button_label']}
        </a>

        <hr />
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
          label={tcap('verbs.login')}
        />
      </form>

      <a href="#/password-recovery" class="password-recovery">
        {tcap('password_forgotten_question')}
      </a>

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

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.info)
    tag.mixin(wApp.mixins.config)
    tag.mixin(wApp.mixins.page)

    tag.on 'mount', ->
      Zepto(tag.root).find('input').first().focus()

    tag.submit = (event) ->
      event.preventDefault()
      username = tag.refs.username.value()
      password = tag.refs.password.value()
      wApp.auth.login(username, password).then ->
        if r = wApp.routing.query()['return_to']
          window.location.hash = decodeURIComponent(r)
        else
          wApp.routing.path '/search'

    tag.federationAuth = ->
      l = tag.config().env_auth_button_label
      typeof l == 'string' && l.length > 0

  </script>
</kor-login>