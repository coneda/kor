riot.tag2('kor-application', '  <div class="container">\n    <a href="#/login">login</a>\n    <a href="#/welcome">welcome</a>\n    <a href="#/search">search</a>\n  </div>\n\n  <kor-js-extensions></kor-js-extensions>\n  <kor-router></kor-router>\n  <kor-notifications></kor-notifications>\n\n  <div id="page-container" class="container">\n    <kor-page class="kor-appear-animation"></kor-page>\n  </div>\n', '@keyframes kor-appear { from { opacity: 0; transform: rotateY(180deg); } to { opacity: 100; } } @keyframes kor-fade { from { opacity: 100; } to { opacity: 0; transform: rotateY(90deg); } } #page-container { perspective: 1000px; } .kor-appear-animation { transform-style: preserve-3d; display: block; animation-name: kor-appear; animation-duration: 1s; } .kor-fade-animation { transform-style: preserve-3d; display: block; animation-name: kor-fade; animation-duration: 1s; }', '', function(opts) {
var mount_page, self;

self = this;

window.kor = {
  init: function() {
    return this.on('mount', function() {});
  },
  url: self.opts.baseUrl || '',
  bus: riot.observable()
};

riot.mixin(kor);

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
  if (self.page_tag) {
    self.page_tag.unmount(true);
  }
  element = $(self.root).find('kor-page');
  self.page_tag = (riot.mount(element[0], tag))[0];
  element.detach();
  return $(self['page-container']).append(element);
};

self.on('mount', function() {
  return mount_page('kor-loading');
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
riot.tag2('kor-login', '  <div class="row">\n    <div class="col-md-3 col-md-offset-4">\n      <div class="panel panel-default">\n        <div class="panel-heading">Login</div>\n        <div class="panel-body">\n          <form class="form" onsubmit="{submit}">\n            <div class="control-group">\n              <label for="kor-login-form-username">Username</label>\n              <input type="text" name="username" class="form-control" id="kor-login-form-username">\n            </div>\n            <div class="control-group">\n              <label for="kor-login-form-password">Password</label>\n              <input type="password" name="password" class="form-control" id="kor-login-form-password">\n            </div>\n            <div class="form-group text-right"></div>\n              <input type="submit" class="form-control btn btn-default">\n            </div>\n          </form>\n        </div>\n      </div>\n    </div>\n  </div>\n', '', '', function(opts) {
var self;

self = this;

self.submit = function() {
  return $.ajax({
    type: 'post',
    url: kor.url + "/login",
    data: JSON.stringify({
      username: $(self['kor-login-form-username']).val(),
      password: $(self['kor-login-form-password']).val()
    }),
    success: function(data) {
      var to;
      kor.info = data;
      kor.bus.trigger('data.info');
      if (to = riot.route.query()['redirect']) {
        return riot.route(decodeURIComponent(to));
      } else {
        return riot.route('/welcome', 'Welcome', false);
      }
    }
  });
};
});
riot.tag2('kor-notifications', '\n  <ul>\n    <li each="{data in messages}" class="bg-warning" onanimationend="{alert(data)}">\n      <i class="glyphicon glyphicon-exclamation-sign"></i>\n      {data.message}\n    </li>\n  </ul>\n', 'kor-notifications ul { perspective: 1000px; position: absolute; top: 0px; right: 0px; } kor-notifications ul li { padding: 1rem; list-style-type: none; }', '', function(opts) {
var fading, self;

self = this;

self.messages = [];

self.history = [];

self.animend = function() {
  return console.log(arguments);
};

fading = function(data) {
  var li;
  self.messages.push(data);
  self.update();
  li = $(self.root).find('li').last();
  return setTimeout((function() {
    return li.addClass('kor-fade-animation');
  }), 2000);
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
var path, query, self;

self = this;

$.ajax({
  type: 'get',
  url: kor.url + "/api/1.0/info",
  success: function(data) {
    kor.info = data;
    return kor.bus.trigger('data.info');
  }
});

path = function() {
  var m;
  if (m = document.location.hash.match(/\#([^?]+)/)) {
    return "/" + m[1];
  } else {
    return void 0;
  }
};

query = function() {
  var m;
  if (m = document.location.hash.match(/\#[^?]*\?(.+)$/)) {
    return "/" + m[1];
  } else {
    return void 0;
  }
};

kor.bus.on('data.info', function() {
  var current;
  if (self.route) {
    self.route.stop();
  }
  self.route = riot.route.create();
  self.route('/login..', function() {
    return kor.bus.trigger('page.login');
  });
  if (kor.info.session.user) {
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
  } else {
    if (path() !== '/login') {
      current = "" + (path());
      if (query()) {
        current = current + "?" + (query());
      }
      current = encodeURIComponent(current);
      self.route(function() {
        return riot.route("/login?redirect=" + current, 'Login', true);
      });
    }
  }
  return riot.route.exec();
});

riot.route.start();
});
riot.tag2('kor-search', '\n  <h1>Search</h1>\n\n  <form class="form">\n    <div class="row">\n      <div class="col-md-3">\n        <div class="form-group">\n          <input type="text" name="terms" placeholder="fulltext search ..." class="form-control" id="kor-search-form-terms">\n        </div>\n      </div>\n    </div>\n    <div class="row">\n      <div class="col-md-12">\n        <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button>\n\n        <div class="checkbox-inline" each="{collection in collections}">\n          <label>\n            <input type="checkbox" value="{collection.id}" checked="true">\n            {collection.name}\n          </label>\n        </div>\n      </div>\n\n      <div class="col-md-12">\n        <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button>\n\n        <div class="checkbox-inline" each="{kind in kinds}">\n          <label>\n            <input type="checkbox" value="{kind.id}" checked="true">\n            {kind.plural_name}\n          </label>\n        </div>\n      </div>\n    </div>\n  </form>\n', 'kor-search .allnone, [data-is=\'kor-search\'] .allnone { margin-right: 1rem; margin-top: -3px; }', '', function(opts) {
var self;

self = this;

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
riot.tag2('kor-welcome', '  <span>Welcome!</span>\n', '', '', function(opts) {
});