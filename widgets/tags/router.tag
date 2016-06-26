<kor-router>
  <script type="text/coffee">
    self = this

    $.ajax(
      type: 'get'
      url: "#{kor.url}/api/1.0/info"
      success: (data) ->
        kor.info = data
        kor.bus.trigger 'data.info'
    )

    path = ->
      if m = document.location.hash.match(/\#([^?]+)/) then "/#{m[1]}" else undefined

    query = ->
      if m = document.location.hash.match(/\#[^?]*\?(.+)$/) then "/#{m[1]}" else undefined

    kor.bus.on 'data.info', ->
      self.route.stop() if self.route

      self.route = riot.route.create()
      self.route '/login..', ->
        kor.bus.trigger 'page.login'
      if kor.info.session.user
        self.route 'welcome', -> kor.bus.trigger 'page.welcome'
        self.route 'search', -> kor.bus.trigger 'page.search'
        self.route 'entities/*', (id) -> kor.bus.trigger 'page.entity', id: id
      else
        unless path() == '/login'
          current = "#{path()}"
          current = "#{current}?#{query()}" if query()
          current = encodeURIComponent(current)
          self.route -> riot.route "/login?redirect=#{current}", 'Login', true
      riot.route.exec()

    riot.route.start()

  </script>
</kor-router>