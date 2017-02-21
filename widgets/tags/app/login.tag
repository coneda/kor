<kor-login>

  <h1>Login</h1>

  <form class="form" method="POST" onsubmit={submit}>
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

      promise = wApp.auth.login(
        tag.refs.username.value(),
        tag.refs.password.value()
      )

      promise.done ->
        wApp.session.setup().done -> riot.update()

  </script>
</kor-login>