<kor-application>
  <div class="container">
    <a href="#/login">login</a>
    <a href="#/welcome">welcome</a>
    <a href="#/search">search</a>
    <a href="#/logout">logout</a>
  </div>

  <kor-js-extensions />
  <kor-router />
  <kor-notifications />

  <div id="page-container" class="container">
    <kor-page class="kor-appear-animation" />
  </div>

  <script type="text/coffee">
    self = this

    window.kor = {
      # init: ->
      #   this.on 'mount', ->
          # console.log this
      url: self.opts.baseUrl || ''
      bus: riot.observable()
      load_session: ->
        Zepto.ajax(
          type: 'get'
          url: "#{kor.url}/api/1.0/info"
          success: (data) ->
            kor.info = data
            kor.bus.trigger 'data.info'
        )
      login: (username, password) ->
        console.log arguments
        Zepto.ajax(
          type: 'post',
          url: "#{kor.url}/login"
          data: JSON.stringify(
            username: username
            password: password
          )
          success: (data) -> kor.load_session()
        )
      logout: ->
        Zepto.ajax(
          type: 'delete'
          url: "#{kor.url}/logout"
          success: -> kor.load_session()
        )
    }
    riot.mixin(kor: kor)

    Zepto.extend Zepto.ajaxSettings, {
      contentType: 'application/json'
      dataType: 'json'
      error: (request) ->
        console.log request
        kor.bus.trigger 'notify', JSON.parse(request.response)
    }

    mount_page = (tag) ->
      if self.mounted_page != tag
        self.page_tag.unmount(true) if self.page_tag
        element = Zepto(self.root).find('kor-page')
        self.page_tag = (riot.mount element[0], tag)[0]
        element.detach()
        Zepto(self['page-container']).append(element)
        self.mounted_page = tag

    self.on 'mount', ->
      mount_page 'kor-loading'
      kor.load_session()
    
    kor.bus.on 'page.welcome', -> mount_page('kor-welcome')
    kor.bus.on 'page.login', -> mount_page('kor-login')
    kor.bus.on 'page.entity', -> mount_page('kor-entity')
    kor.bus.on 'page.search', -> mount_page('kor-search')

  </script>
</kor-application>