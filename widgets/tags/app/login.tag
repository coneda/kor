<kor-login>

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

    <hr />

    <kor-input
      type="submit"
    />
  </form>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.submit = (event) ->
      event.preventDefault()
      username = tag.refs.username.value()
      password = tag.refs.password.value()
      wApp.auth.login(username, password).then ->
        wApp.bus.trigger 'routing:path', wApp.routing.parts()

  </script>
</kor-login>