<w-app-loader>

  <div class="app" ref="target">
    <div class="kor-loading-screen">
      <img src="/images/loading.gif"><br />
      <strong>… loading …</strong>
    </div>
  </div>

  <script type="text/javascript">
    var tag = this;

    var reloadApp = function() {
      unmount();

      var preloaders = wApp.setup();
      $.when.apply(null, preloaders).then(function() {
        mountApp();
      });
    }

    var unmount = function() {
      if (tag.mountedApp) {
        tag.mountedApp.unmount(true);
      }
    }

    var mountApp = function() {
      var opts = {routing: true};
      tag.mountedApp = riot.mount(tag.refs.target, 'w-app', opts)[0]
      console.log('application (re)loaded');
    }

    wApp.bus.on('reload-app', reloadApp);
    tag.on('mount', function() {
      wApp.bus.trigger('reload-app')
    })
  </script>

</w-app-loader>