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
      updateLayout();
      var opts = {routing: true};
      tag.mountedApp = riot.mount(tag.refs.target, 'w-app', opts)[0]
      console.log('application (re)loaded');
    }

    // this update the page layout with some dynamic content, such as language,
    // custom css etc
    var updateLayout = function() {
      var meta = Zepto('meta[http-equiv=content-language]');
      var locale = wApp.session.current.locale
      meta.attr('content', locale);

      var m = Zepto('<meta>').
        attr('name', 'description').
        attr('content', wApp.i18n.t(locale, 'meta.description'));
      meta.after(m);

      m = Zepto('<meta>').
        attr('name', 'author').
        attr('content', wApp.i18n.t(locale, 'meta.author'));
      meta.after(m);

      m = Zepto('<meta>').
        attr('name', 'description').
        attr('keywords', wApp.i18n.t(locale, 'meta.keywords'));
      meta.after(m);

      var url = wApp.info.data.custom_css;
      if (url) {
        var link = Zepto('<link rel="stylesheet" href="' + url + '">');
        Zepto('head').append(link);
      }
    }

    wApp.bus.on('reload-app', reloadApp);
    tag.on('mount', function() {
      wApp.bus.trigger('reload-app')
    })
  </script>

</w-app-loader>