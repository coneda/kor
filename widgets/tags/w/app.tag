<w-app>
  <kor-header />

  <div>
    <kor-menu />
    <div class="w-content" />
    <kor-footer />
  </div>

  <w-modal ref="modal" />
  <w-messaging />

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.auth);

  window.kor = tag;

  // On mount, set up event listeners and routing
  tag.on('mount', function() {
    wApp.bus.on('routing:path', tag.routeHandler);
    wApp.bus.on('routing:query', tag.queryHandler);
    wApp.bus.on('page-title', pageTitleHandler);
    wApp.bus.on('access-denied', accessDenied);
    wApp.bus.on('go-back', goBack);
    wApp.bus.on('query-update', queryUpdate);
    wApp.bus.on('server-code', serverCodeHandler);
    if (tag.opts.routing) {
      wApp.routing.setup();
    }
  });

  // On unmount, remove event listeners and routing
  tag.on('unmount', function() {
    wApp.bus.off('page-title', pageTitleHandler);
    wApp.bus.off('routing:query', tag.queryHandler);
    wApp.bus.off('routing:path', tag.routeHandler);
    wApp.bus.off('access-denied', accessDenied);
    wApp.bus.off('go-back', goBack);
    wApp.bus.off('query-update', queryUpdate);
    wApp.bus.off('server-code', serverCodeHandler);
    if (tag.opts.routing) {
      wApp.routing.tearDown();
    }
  });

  // Update page title
  var pageTitleHandler = function(newTitle) {
    var nv = newTitle ? newTitle : 'ConedaKOR';
    Zepto('head title').html(nv);
  };

  // Handle access denied
  var accessDenied = function() {
    if (tag.mountInProgress) {
      window.requestAnimationFrame(() => tag.mountTag('kor-access-denied'))
    } else {
      tag.mountTag('kor-access-denied');
    }
  };

  // Handle server code
  var serverCodeHandler = function(code) {
    if (code === 'terms-not-accepted') {
      redirectTo('/legal');
    }
  };

  // Go back in routing history
  var goBack = function() {
    wApp.routing.back();
  };

  // Update query in routing
  var queryUpdate = function(newQuery) {
    wApp.routing.query(newQuery);
  };

  // Handle routing paths
  tag.routeHandler = function(parts) {
    var tagName = 'kor-loading';
    var opts = {
      query: parts['hash_query']
    };

    var path = parts['hash_path'];
    switch (path) {
      case undefined:
      case '':
      case '/':
        tagName = 'kor-welcome';
        break;
      case '/login':
        if (tag.currentUser() && !tag.isGuest()) {
          redirectTo('/search');
        } else {
          tagName = 'kor-login';
        }
        break;
      case '/statistics':
        tagName = 'kor-statistics';
        break;
      case '/legal':
        tagName = 'kor-legal';
        break;
      case '/about':
        tagName = 'kor-about';
        break;
      default:
        if (tag.currentUser()) {
          if (!tag.isGuest() && !tag.currentUser().terms_accepted && path !== '/legal') {
            redirectTo('/legal');
          } else {
            var m;
            if ((m = path.match(/^\/users\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-user-editor';
            } else if ((m = path.match(/^\/entities\/([0-9]+)$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-entity-page';
            } else if ((m = path.match(/^\/kinds\/([0-9]+)\/edit\/fields\/new$/))) {
              opts['id'] = parseInt(m[1]);
              opts['newField'] = true;
              tagName = 'kor-kind-editor';
            } else if ((m = path.match(/^\/kinds\/([0-9]+)\/edit\/fields\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              opts['fieldId'] = parseInt(m[2]);
              tagName = 'kor-kind-editor';
            } else if ((m = path.match(/^\/kinds\/([0-9]+)\/edit\/generators\/new$/))) {
              opts['id'] = parseInt(m[1]);
              opts['newGenerator'] = true;
              tagName = 'kor-kind-editor';
            } else if ((m = path.match(/^\/kinds\/([0-9]+)\/edit\/generators\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              opts['generatorId'] = parseInt(m[2]);
              tagName = 'kor-kind-editor';
            } else if ((m = path.match(/^\/kinds\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-kind-editor';
            } else if ((m = path.match(/^\/entities\/new$/))) {
              opts['kindId'] = parts['hash_query']['kind_id'];
              opts['cloneId'] = parts['hash_query']['clone_id'];
              tagName = 'kor-entity-editor';
            } else if ((m = path.match(/^\/entities\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-entity-editor';
            } else if ((m = path.match(/^\/credentials\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-credential-editor';
            } else if ((m = path.match(/^\/collections\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-collection-editor';
            } else if ((m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/new$/))) {
              opts['parentId'] = parseInt(m[1]);
              tagName = 'kor-admin-group-category-editor';
            } else if ((m = path.match(/^\/groups\/categories\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-admin-group-category-editor';
            } else if ((m = path.match(/^\/groups\/categories(?:\/([0-9]+))?$/))) {
              if (m[1]) {
                opts['parentId'] = parseInt(m[1]);
              }
              tagName = 'kor-admin-group-categories';
            } else if ((m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/admin\/([0-9]+)\/edit$/))) {
              opts['categoryId'] = parseInt(m[1]);
              opts['id'] = parseInt(m[2]);
              tagName = 'kor-admin-group-editor';
            } else if ((m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/admin\/new$/))) {
              opts['categoryId'] = parseInt(m[1]);
              tagName = 'kor-admin-group-editor';
            } else if ((m = path.match(/^\/groups\/admin\/([0-9]+)$/))) {
              opts['id'] = parseInt(m[1]);
              opts['type'] = 'authority';
              tagName = 'kor-entity-group';
            } else if ((m = path.match(/^\/groups\/user\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-user-group-editor';
            } else if ((m = path.match(/^\/groups\/user\/([0-9]+)$/))) {
              opts['id'] = parseInt(m[1]);
              opts['type'] = 'user';
              tagName = 'kor-entity-group';
            } else if ((m = path.match(/^\/relations\/([0-9]+)\/edit$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-relation-editor';
            } else if ((m = path.match(/^\/media\/([0-9]+)$/))) {
              opts['id'] = parseInt(m[1]);
              tagName = 'kor-medium-page';
            } else if ((m = path.match(/^\/pub\/([0-9]+)\/([0-9a-f]+)$/))) {
              opts['userId'] = parseInt(m[1]);
              opts['uuid'] = m[2];
              tagName = 'kor-publishment';
            } else {
              switch (path) {
                case '/clipboard':
                  tagName = 'kor-clipboard';
                  break;
                case '/profile':
                  tagName = 'kor-profile';
                  break;
                case '/new-media':
                  tagName = 'kor-new-media';
                  break;
                case '/users/new':
                  tagName = 'kor-user-editor';
                  break;
                case '/users':
                  tagName = 'kor-users';
                  break;
                case '/entities/invalid':
                  tagName = 'kor-invalid-entities';
                  break;
                case '/entities/recent':
                  tagName = 'kor-recent-entities';
                  break;
                case '/entities/isolated':
                  tagName = 'kor-isolated-entities';
                  break;
                case '/search':
                  tagName = 'kor-search';
                  break;
                case '/kinds':
                  tagName = 'kor-kinds';
                  break;
                case '/kinds/new':
                  tagName = 'kor-kind-editor';
                  break;
                case '/credentials':
                  tagName = 'kor-credentials';
                  break;
                case '/credentials/new':
                  tagName = 'kor-credential-editor';
                  break;
                case '/collections':
                  tagName = 'kor-collections';
                  break;
                case '/collections/new':
                  tagName = 'kor-collection-editor';
                  break;
                case '/upload':
                  tagName = 'kor-upload';
                  break;
                case '/groups/user/new':
                  tagName = 'kor-user-group-editor';
                  break;
                case '/groups/user':
                  tagName = 'kor-user-groups';
                  break;
                case '/groups/shared':
                  opts['type'] = 'shared';
                  tagName = 'kor-user-groups';
                  break;
                case '/relations/new':
                  tagName = 'kor-relation-editor';
                  break;
                case '/relations':
                  tagName = 'kor-relations';
                  break;
                case '/settings':
                  tagName = 'kor-settings-editor';
                  break;
                case '/password-recovery':
                  tagName = 'kor-password-recovery';
                  break;
                case '/groups/published':
                  tagName = 'kor-publishments';
                  break;
                case '/groups/published/new':
                  tagName = 'kor-publishment-editor';
                  break;
                default:
                  tagName = 'kor-search';
              }
            }
          }
        } else {
          tagName = 'kor-login';
        }
    }

    tag.closeModal();
    tag.mountTagAndAnimate(tagName, opts);
  };

  // Handle query updates
  tag.queryHandler = function(parts) {
    if (tag.mountedTag) {
      tag.mountedTag.opts.query = parts['hash_query'];
      tag.mountedTag.trigger('routing:query');
    }
  };

  // Close modal
  tag.closeModal = function() {
    tag.refs.modal.trigger('close');
  };

  // Mount tag with animation
  tag.mountTagAndAnimate = function(tagName, opts = {}) {
    if (tagName) {
      var element = Zepto(tag.root).find('.w-content');

      function mountIt() {
        wApp.bus.trigger('page-title');
        tag.mountInProgress = true
        tag.mountedTag = riot.mount(element[0], tagName, opts)[0];
        tag.mountInProgress = false
        if (wApp.info.data.env !== 'test') {
          element.animate({ opacity: 1.0 }, 200);
        }
        wApp.utils.scrollToTop();
      }

      if (tag.mountedTag) {
        if (wApp.info.data.env !== 'test') {
          element.animate({ opacity: 0.0 }, 200, function() {
            tag.mountedTag.unmount(true);
            mountIt();
          });
        } else {
          tag.mountedTag.unmount(true);
          mountIt();
        }
      } else {
        mountIt();
      }
    }
  };

  // Mount tag without animation
  tag.mountTag = function(tagName, opts = {}) {
    if (tagName) {
      var element = Zepto('.w-content');
      if (tag.mountedTag) {
        tag.mountedTag.unmount(true);
      }
      tag.mountInProgress = true
      tag.mountedTag = riot.mount(element[0], tagName, opts)[0];
      tag.mountInProgress = false
      wApp.utils.scrollToTop();
    }
  };

  // Redirect to a new path
  var redirectTo = function(newPath) {
    wApp.routing.path(newPath);
    return null;
  };
</script>
</w-app>
