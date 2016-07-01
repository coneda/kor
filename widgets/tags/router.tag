<kor-router>
  <script type="text/coffee">
    self = this

    routing = {
      path: ->
        if m = document.location.hash.match(/\#([^?]+)/) then "#{m[1]}" else undefined
      query: (params) ->
        if params
          result = {}
          $.extend(result, route.query(), params)
          qs = []
          for k, v of result
            if result[k] != null
              qs.push "#{k}=#{v}"
          route "#{routing.path()}?#{qs.join '&'}"
        route.query()
      state: {
        update: (values = {}) ->
          old_state = routing.state.get()
          for k, v of values
            if v == null
              delete old_state[k]
            else
              old_state[k] = v
          routing.state.set(old_state)
        get: (what) ->
          switch what
            when 'base' then routing.query()['q']
            when 'json'
              if base = routing.state.get('base')
                routing.state.unpack(base)
              else
                '{}'
            else
              if json = routing.state.get('json')
                routing.state.deserialize(json)
              else
                {}
        set: (values = null) ->
          if values == null || values == {}
            routing.query(q: null)
          else
            if routing.state.serialize(values) == '{}'
              routing.query q: null
            else
              json = routing.state.serialize(values)
              base = routing.state.pack(json)
              routing.query q: base
        serialize: (data) -> JSON.stringify(data)
        deserialize: (str) -> JSON.parse(str)
        pack: (json = {}) -> btoa(json)
        unpack: (str) -> atob(str)
      }
      register: ->
        context = route.create()
        old_state = undefined
        context '..', ->
          new_state = routing.state.get('base')
          if new_state != old_state
            self.kor.bus.trigger 'query.data', routing.state.get()
            old_state = new_state

    }
    self.kor.routing = routing
    routing.register()

    kor.bus.on 'data.info', ->
      self.route.stop() if self.route

      if kor.info.session.user
        self.route = route.create()
        self.route 'welcome', -> kor.bus.trigger 'page.welcome'
        self.route 'search', -> kor.bus.trigger 'page.search'
        self.route 'entities/*', (id) -> kor.bus.trigger 'page.entity', id: id
        self.route 'logout', -> kor.logout()
        route.exec()
      else
        kor.bus.trigger 'page.login'

    route.start()

  </script>
</kor-router>