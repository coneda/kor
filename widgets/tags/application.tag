<kor-application>
  <div class="container">
    <a href="#/login">login</a>
    <a href="#/welcome">welcome</a>
    <a href="#/search">search</a>
  </div>

  <kor-js-extensions />
  <kor-router />
  <kor-notifications />

  <div id="page-container" class="container">
    <kor-page class="kor-appear-animation" />
  </div>

  <style type="text/scss">
    @keyframes kor-appear {
      from {
        opacity: 0;
        transform: rotateY(180deg)
      };
      to {opacity: 100;};
    }

    #page-container {
      perspective: 1000px;
    }

    .kor-appear-animation {
      transform-style: preserve-3d;
      display: block;
      animation-name: kor-appear;
      animation-duration: 1s;
    }

    kor-page {
      /*background-color: yellow;*/
    }
  </style>

  <script type="text/coffee">
    self = this

    window.kor = {
      init: ->
        this.on 'mount', ->
          # console.log this
      url: self.opts.baseUrl || ''
      bus: riot.observable()
    }
    riot.mixin(kor)

    $.extend $.ajaxSettings, {
      contentType: 'application/json'
      dataType: 'json'
      error: (request) ->
        console.log request
        kor.bus.trigger 'notify', JSON.parse(request.response)
    }

    mount_page = (tag) ->
      self.page_tag.unmount(true) if self.page_tag
      element = $(self.root).find('kor-page')
      self.page_tag = (riot.mount element[0], tag)[0]
      element.detach()
      $(self['page-container']).append(element)

    self.on 'mount', -> mount_page 'kor-loading'
    
    kor.bus.on 'page.welcome', -> mount_page('kor-welcome')
    kor.bus.on 'page.login', -> mount_page('kor-login')
    kor.bus.on 'page.entity', -> mount_page('kor-entity')
    kor.bus.on 'page.search', -> mount_page('kor-search')

  </script>
</kor-application>