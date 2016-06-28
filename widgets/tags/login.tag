<kor-login>
  <div class="row">
    <div class="col-md-3 col-md-offset-4">
      <div class="panel panel-default">
        <div class="panel-heading">Login</div>
        <div class="panel-body">
          <form class="form" onsubmit={submit} >
            <div class="control-group">
              <label for="kor-login-form-username">Username</label>
              <input
                type="text"
                name="username"
                class="form-control"
                id="kor-login-form-username"
              />
            </div>
            <div class="control-group">
              <label for="kor-login-form-password">Password</label>
              <input
                type="password"
                name="password"
                class="form-control"
                id="kor-login-form-password"
              />
            </div>
            <div class="form-group text-right"></div>
              <input type="submit" class="form-control btn btn-default" />
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <script type="text/coffee">
    self = this

    self.submit = ->
      $.ajax(
        type: 'post',
        url: "#{kor.url}/login"
        data: JSON.stringify(
          username: $(self['kor-login-form-username']).val()
          password: $(self['kor-login-form-password']).val()
        )
        success: (data) ->
          kor.info = data
          kor.bus.trigger 'data.info'

          if to = riot.route.query()['redirect']
            riot.route decodeURIComponent(to)
          else
            riot.route '/welcome', 'Welcome', false
      )
  </script>
</kor-login>