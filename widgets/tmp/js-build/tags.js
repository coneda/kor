riot.tag2('kor-application', '  <div class="container">\n    <a href="#/login">login</a>\n    <a href="#/welcome">welcome</a>\n    <a href="#/search">search</a>\n    <a href="#/logout">logout</a>\n  </div>\n\n  <kor-js-extensions></kor-js-extensions>\n  <kor-router></kor-router>\n  <kor-notifications></kor-notifications>\n\n  <div id="page-container" class="container">\n    <kor-page class="kor-appear-animation"></kor-page>\n  </div>\n', '@keyframes kor-appear { from { opacity: 0; transform: translateX(100%); } to { opacity: 100; transform: translateX(0%); } } @keyframes kor-fade { from { opacity: 100; } to { opacity: 0; transform: rotateY(90deg); } } #page-container { perspective: 1000px; } .kor-appear-animation { transform-style: preserve-3d; display: block; animation-name: kor-appear; animation-duration: 500ms; } .kor-fade-animation { transform-style: preserve-3d; display: block; animation-name: kor-fade; animation-duration: 500ms; }', '', function(opts) {
var mount_page, self;

self = this;

window.kor = {
  url: self.opts.baseUrl || '',
  bus: riot.observable(),
  load_session: function() {
    return $.ajax({
      type: 'get',
      url: kor.url + "/api/1.0/info",
      success: function(data) {
        kor.info = data;
        return kor.bus.trigger('data.info');
      }
    });
  },
  login: function(username, password) {
    console.log(arguments);
    return $.ajax({
      type: 'post',
      url: kor.url + "/login",
      data: JSON.stringify({
        username: username,
        password: password
      }),
      success: function(data) {
        return kor.load_session();
      }
    });
  },
  logout: function() {
    return $.ajax({
      type: 'delete',
      url: kor.url + "/logout",
      success: function() {
        return kor.load_session();
      }
    });
  }
};

riot.mixin({
  kor: kor
});

$.extend($.ajaxSettings, {
  contentType: 'application/json',
  dataType: 'json',
  error: function(request) {
    console.log(request);
    return kor.bus.trigger('notify', JSON.parse(request.response));
  }
});

mount_page = function(tag) {
  var element;
  if (self.mounted_page !== tag) {
    if (self.page_tag) {
      self.page_tag.unmount(true);
    }
    element = $(self.root).find('kor-page');
    self.page_tag = (riot.mount(element[0], tag))[0];
    element.detach();
    $(self['page-container']).append(element);
    return self.mounted_page = tag;
  }
};

self.on('mount', function() {
  mount_page('kor-loading');
  return kor.load_session();
});

kor.bus.on('page.welcome', function() {
  return mount_page('kor-welcome');
});

kor.bus.on('page.login', function() {
  return mount_page('kor-login');
});

kor.bus.on('page.entity', function() {
  return mount_page('kor-entity');
});

kor.bus.on('page.search', function() {
  return mount_page('kor-search');
});
});
riot.tag2('kor-entity', '  <span>Entity X</span>\n', '', '', function(opts) {
});
riot.tag2('kor-js-extensions', '', '', '', function(opts) {
var self;

self = this;
});
riot.tag2('kor-loading', '  <span>... loading ...</span>\n', '', '', function(opts) {
});
riot.tag2('kor-login', '  <div class="row">\n    <div class="col-md-3 col-md-offset-4">\n      <div class="panel panel-default">\n        <div class="panel-heading">Login</div>\n        <div class="panel-body">\n          <form class="form" method="POST" onsubmit="{submit}">\n            <div class="control-group">\n              <label for="kor-login-form-username">Username</label>\n              <input type="text" name="username" class="form-control" id="kor-login-form-username">\n            </div>\n            <div class="control-group">\n              <label for="kor-login-form-password">Password</label>\n              <input type="password" name="password" class="form-control" id="kor-login-form-password">\n            </div>\n            <div class="form-group text-right"></div>\n              <input type="submit" class="form-control btn btn-default">\n            </div>\n          </form>\n        </div>\n      </div>\n    </div>\n  </div>\n', '', '', function(opts) {
var self;

self = this;

self.on('mount', function() {
  return $(self.root).find('input')[0].focus();
});

self.submit = function(event) {
  event.preventDefault();
  return kor.login($(self['kor-login-form-username']).val(), $(self['kor-login-form-password']).val());
};
});
riot.tag2('kor-notifications', '\n  <ul>\n    <li each="{data in messages}" class="bg-warning {kor-fade-animation: data.remove}" onanimationend="{parent.animend}">\n      <i class="glyphicon glyphicon-exclamation-sign"></i>\n      {data.message}\n    </li>\n  </ul>\n', 'kor-notifications ul { perspective: 1000px; position: absolute; top: 0px; right: 0px; } kor-notifications ul li { padding: 1rem; list-style-type: none; }', '', function(opts) {
var fading, self;

self = this;

self.messages = [];

self.history = [];

self.animend = function(event) {
  var i;
  i = self.messages.indexOf(event.item.data);
  self.history.push(self.messages[i]);
  self.messages.splice(i, 1);
  return self.update();
};

fading = function(data) {
  self.messages.push(data);
  self.update();
  return setTimeout((function() {
    data.remove = true;
    return self.update();
  }), 5000);
};

kor.bus.on('notify', function(data) {
  var type;
  type = data.type || 'default';
  if (type === 'default') {
    fading(data);
  }
  return self.update();
});
});
riot.tag2('kor-router', '', '', '', function(opts) {
var routing, self;

self = this;

routing = {
  path: function() {
    var m;
    if (m = document.location.hash.match(/\#([^?]+)/)) {
      return "" + m[1];
    } else {
      return void 0;
    }
  },
  query: function(params) {
    var k, qs, result, v;
    if (params) {
      result = {};
      $.extend(result, route.query(), params);
      qs = [];
      for (k in result) {
        v = result[k];
        if (result[k] !== null) {
          qs.push(k + "=" + v);
        }
      }
      route((routing.path()) + "?" + (qs.join('&')));
    }
    return route.query();
  },
  state: {
    update: function(values) {
      var k, old_state, v;
      if (values == null) {
        values = {};
      }
      old_state = routing.state.get();
      for (k in values) {
        v = values[k];
        if (v === null) {
          delete old_state[k];
        } else {
          old_state[k] = v;
        }
      }
      return routing.state.set(old_state);
    },
    get: function(what) {
      var base, json;
      switch (what) {
        case 'base':
          return routing.query()['q'];
        case 'json':
          if (base = routing.state.get('base')) {
            return routing.state.unpack(base);
          } else {
            return '{}';
          }
          break;
        default:
          if (json = routing.state.get('json')) {
            return routing.state.deserialize(json);
          } else {
            return {};
          }
      }
    },
    set: function(values) {
      var base, json;
      if (values == null) {
        values = null;
      }
      if (values === null || values === {}) {
        return routing.query({
          q: null
        });
      } else {
        if (routing.state.serialize(values) === '{}') {
          return routing.query({
            q: null
          });
        } else {
          json = routing.state.serialize(values);
          base = routing.state.pack(json);
          return routing.query({
            q: base
          });
        }
      }
    },
    serialize: function(data) {
      return JSON.stringify(data);
    },
    deserialize: function(str) {
      return JSON.parse(str);
    },
    pack: function(json) {
      if (json == null) {
        json = {};
      }
      return btoa(json);
    },
    unpack: function(str) {
      return atob(str);
    }
  },
  register: function() {
    var context, old_state;
    context = route.create();
    old_state = void 0;
    return context('..', function() {
      var new_state;
      new_state = routing.state.get('base');
      if (new_state !== old_state) {
        self.kor.bus.trigger('query.data', routing.state.get());
        return old_state = new_state;
      }
    });
  }
};

self.kor.routing = routing;

routing.register();

kor.bus.on('data.info', function() {
  if (self.route) {
    self.route.stop();
  }
  if (kor.info.session.user) {
    self.route = route.create();
    self.route('welcome', function() {
      return kor.bus.trigger('page.welcome');
    });
    self.route('search', function() {
      return kor.bus.trigger('page.search');
    });
    self.route('entities/*', function(id) {
      return kor.bus.trigger('page.entity', {
        id: id
      });
    });
    self.route('logout', function() {
      return kor.logout();
    });
    return route.exec();
  } else {
    return kor.bus.trigger('page.login');
  }
});

route.start();
});
riot.tag2('kor-search', '\n  <h1>Search</h1>\n\n  <form class="form">\n    <div class="row">\n      <div class="col-md-3">\n        <div class="form-group">\n          <input type="text" name="terms" placeholder="fulltext search ..." class="form-control" id="kor-search-form-terms" onchange="{changed}">\n        </div>\n      </div>\n    </div>\n    <div class="row">\n      <div class="col-md-12 collections">\n        <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button>\n\n        <div class="checkbox-inline" each="{collection in collections}">\n          <label>\n            <input type="checkbox" value="{collection.id}" checked="true">\n            {collection.name}\n          </label>\n        </div>\n      </div>\n\n      <div class="col-md-12 kinds">\n        <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button>\n\n        <div class="checkbox-inline" each="{kind in kinds}">\n          <label>\n            <input type="checkbox" value="{kind.id}" checked="true" onchange="{changed}">\n            {kind.plural_name}\n          </label>\n        </div>\n      </div>\n    </div>\n  </form>\n', 'kor-search .allnone, [data-is=\'kor-search\'] .allnone { margin-right: 1rem; margin-top: -3px; }', '', function(opts) {
var self;

self = this;

window.x = this;

self.on('mount', function() {
  $.ajax({
    type: 'get',
    url: kor.url + "/kinds",
    success: function(data) {
      self.kinds = data;
      return self.update();
    }
  });
  return $.ajax({
    type: 'get',
    url: kor.url + "/collections",
    success: function(data) {
      self.collections = data;
      return self.update();
    }
  });
});

self.changed = function(event) {
  var cb, collection_ids, i, j, kind_ids, len, len1, ref, ref1;
  kind_ids = [];
  ref = $(self.root).find('.kindss input[type=checkbox]');
  for (i = 0, len = ref.length; i < len; i++) {
    cb = ref[i];
    if ($(cb).is(':checked')) {
      kind_ids.push(cb.attr);
    }
  }
  collection_ids = [];
  ref1 = $(self.root).find('.collections input[type=checkbox]');
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    cb = ref1[j];
    if ($(cb).is(':checked')) {
      collection_ids.push(cb.attr);
    }
  }
  return self.kor.routing.update({
    terms: $(self.terms).val(),
    collection_ids: collection_ids,
    kinds_ids: kind_ids
  });
};

self.allnone = function(event) {
  var box, boxes, i, len;
  boxes = $(event.target).parent().find('input[type=checkbox]');
  for (i = 0, len = boxes.length; i < len; i++) {
    box = boxes[i];
    console.log($(box).is(':checked'));
    if (!$(box).is(':checked')) {
      console.log(boxes);
      boxes.prop('checked', true);
      return;
    }
  }
  return boxes.prop('checked', null);
};
});
riot.tag2('kor-welcome', '  <h2>Welcome</h2>\n', '', '', function(opts) {
});