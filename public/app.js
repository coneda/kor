!function(root,factory){"undefined"!=typeof exports?"undefined"!=typeof module&&module.exports&&(exports=module.exports=factory(root,exports)):"function"==typeof define&&define.amd?define(["exports"],function(exports){root.Lockr=factory(root,exports)}):root.Lockr=factory(root,{})}(this,function(root,Lockr){"use strict";return Array.prototype.indexOf||(Array.prototype.indexOf=function(elt){var len=this.length>>>0,from=Number(arguments[1])||0;for(from=0>from?Math.ceil(from):Math.floor(from),0>from&&(from+=len);len>from;from++)if(from in this&&this[from]===elt)return from;return-1}),Lockr.prefix="",Lockr._getPrefixedKey=function(key,options){return options=options||{},options.noPrefix?key:this.prefix+key},Lockr.set=function(key,value,options){var query_key=this._getPrefixedKey(key,options);try{localStorage.setItem(query_key,JSON.stringify({data:value}))}catch(e){console&&console.warn("Lockr didn't successfully save the '{"+key+": "+value+"}' pair, because the localStorage is full.")}},Lockr.get=function(key,missing,options){var value,query_key=this._getPrefixedKey(key,options);try{value=JSON.parse(localStorage.getItem(query_key))}catch(e){try{value=localStorage[query_key]?JSON.parse('{"data":"'+localStorage.getItem(query_key)+'"}'):null}catch(e){console&&console.warn("Lockr could not load the item with key "+key)}}return null===value?missing:"undefined"!=typeof value.data?value.data:missing},Lockr.sadd=function(key,value,options){var json,query_key=this._getPrefixedKey(key,options),values=Lockr.smembers(key);if(values.indexOf(value)>-1)return null;try{values.push(value),json=JSON.stringify({data:values}),localStorage.setItem(query_key,json)}catch(e){console.log(e),console&&console.warn("Lockr didn't successfully add the "+value+" to "+key+" set, because the localStorage is full.")}},Lockr.smembers=function(key,options){var value,query_key=this._getPrefixedKey(key,options);try{value=JSON.parse(localStorage.getItem(query_key))}catch(e){value=null}return null===value?[]:value.data||[]},Lockr.sismember=function(key,value,options){this._getPrefixedKey(key,options);return Lockr.smembers(key).indexOf(value)>-1},Lockr.getAll=function(){var keys=Object.keys(localStorage);return keys.map(function(key){return Lockr.get(key)})},Lockr.srem=function(key,value,options){var json,index,query_key=this._getPrefixedKey(key,options),values=Lockr.smembers(key,value);index=values.indexOf(value),index>-1&&values.splice(index,1),json=JSON.stringify({data:values});try{localStorage.setItem(query_key,json)}catch(e){console&&console.warn("Lockr couldn't remove the "+value+" from the set "+key)}},Lockr.rm=function(key){localStorage.removeItem(key)},Lockr.flush=function(){localStorage.clear()},Lockr});(function(){"use strict";var e=function(e){e=e||{};var t={},n=Array.prototype.slice,r=function(e,t){e.replace(/\S+/g,t)};Object.defineProperties(e,{on:{value:function(n,i){if(typeof i!="function")return e;r(n,function(e,n){(t[e]=t[e]||[]).push(i);i.typed=n>0});return e},enumerable:false,writable:false,configurable:false},off:{value:function(n,i){if(n=="*"&&!i)t={};else{r(n,function(e){if(i){var n=t[e];for(var r=0,f;f=n&&n[r];++r){if(f==i)n.splice(r--,1)}}else delete t[e]})}return e},enumerable:false,writable:false,configurable:false},one:{value:function(t,n){function r(){e.off(t,r);n.apply(e,arguments)}return e.on(t,r)},enumerable:false,writable:false,configurable:false},trigger:{value:function(i){var f=arguments.length-1,u=new Array(f),o;for(var a=0;a<f;a++){u[a]=arguments[a+1]}r(i,function(r){o=n.call(t[r]||[],0);for(var i=0,f;f=o[i];++i){if(f.busy)return;f.busy=1;f.apply(e,f.typed?[r].concat(u):u);if(o[i]!==f){i--}f.busy=0}if(t["*"]&&r!="*")e.trigger.apply(e,["*",r].concat(u))});return e},enumerable:false,writable:false,configurable:false}});return e};var t=/^.+?\/\/+[^\/]+/,n="EventListener",r="remove"+n,i="add"+n,f="hasAttribute",u="replace",o="popstate",a="hashchange",c="trigger",l=3,s=typeof window!="undefined"&&window,h=typeof document!="undefined"&&document,p=s&&history,d=s&&(p.location||s.location),v=j.prototype,b=h&&h.ontouchstart?"touchstart":"click",m=false,y=e(),g=false,w,$,A,x,S,K=[],N=0;function O(e){return e.split(/[\/?#]/)}function T(e,t){var n=new RegExp("^"+t[u](/\*/g,"([^/?#]+?)")[u](/\.\./,".*")+"$"),r=e.match(n);if(r)return r.slice(1)}function E(e,t){var n;return function(){clearTimeout(n);n=setTimeout(e,t)}}function P(e){w=E(R,1);s[i](o,w);s[i](a,w);h[i](b,_);if(e)R(true)}function j(){this.$=[];e(this);y.on("stop",this.s.bind(this));y.on("emit",this.e.bind(this))}function k(e){return e[u](/^\/|\/$/,"")}function q(e){return typeof e=="string"}function D(e){return(e||d.href)[u](t,"")}function L(e){return $[0]=="#"?(e||d.href||"").split($)[1]||"":(d?D(e):e||"")[u]($,"")}function R(e){var t=N==0;if(l<=N)return;N++;K.push(function(){var t=L();if(e||t!=A){y[c]("emit",t);A=t}});if(t){while(K.length){K[0]();K.shift()}N=0}}function _(e){if(e.which!=1||e.metaKey||e.ctrlKey||e.shiftKey||e.defaultPrevented)return;var n=e.target;while(n&&n.nodeName!="A")n=n.parentNode;if(!n||n.nodeName!="A"||n[f]("download")||!n[f]("href")||n.target&&n.target!="_self"||n.href.indexOf(d.href.match(t)[0])==-1)return;if(n.href!=d.href){if(n.href.split("#")[0]==d.href.split("#")[0]||$!="#"&&D(n.href).indexOf($)!==0||!z(L(n.href),n.title||h.title))return}e.preventDefault()}function z(e,t,n){if(p){e=$+k(e);t=t||h.title;n?p.replaceState(null,t,e):p.pushState(null,t,e);h.title=t;g=false;R();return g}return y[c]("emit",L(e))}v.m=function(e,t,n){if(q(e)&&(!t||q(t)))z(e,t,n||false);else if(t)this.r(e,t);else this.r("@",e)};v.s=function(){this.off("*");this.$=[]};v.e=function(e){this.$.concat("@").some(function(t){var n=(t=="@"?x:S)(k(e),k(t));if(typeof n!="undefined"){this[c].apply(null,[t].concat(n));return g=true}},this)};v.r=function(e,t){if(e!="@"){e="/"+k(e);this.$.push(e)}this.on(e,t)};var B=new j;var C=B.m.bind(B);C.create=function(){var e=new j;var t=e.m.bind(e);t.stop=e.s.bind(e);return t};C.base=function(e){$=e||"#";A=L()};C.exec=function(){R(true)};C.parser=function(e,t){if(!e&&!t){x=O;S=T}if(e)x=e;if(t)S=t};C.query=function(){var e={};var t=d.href||A;t[u](/[?&](.+?)=([^&]*)/g,function(t,n,r){e[n]=r});return e};C.stop=function(){if(m){if(s){s[r](o,w);s[r](a,w);h[r](b,_)}y[c]("stop");m=false}};C.start=function(e){if(!m){if(s){if(document.readyState=="complete")P(e);else s[i]("load",function(){setTimeout(function(){P(e)},1)})}m=true}};C.base();C.parser();window.route=C})();riot.tag2('kor-application', '  <div class="container">\n    <a href="#/login">login</a>\n    <a href="#/welcome">welcome</a>\n    <a href="#/search">search</a>\n    <a href="#/logout">logout</a>\n  </div>\n\n  <kor-js-extensions></kor-js-extensions>\n  <kor-router></kor-router>\n  <kor-notifications></kor-notifications>\n\n  <div id="page-container" class="container">\n    <kor-page class="kor-appear-animation"></kor-page>\n  </div>\n', '@keyframes kor-appear { from { opacity: 0; transform: translateX(100%); } to { opacity: 100; transform: translateX(0%); } } @keyframes kor-fade { from { opacity: 100; } to { opacity: 0; transform: rotateY(90deg); } } #page-container { perspective: 1000px; } .kor-appear-animation { transform-style: preserve-3d; display: block; animation-name: kor-appear; animation-duration: 500ms; } .kor-fade-animation { transform-style: preserve-3d; display: block; animation-name: kor-fade; animation-duration: 500ms; }', '', function(opts) {
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
    self.route('search..', function() {
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
riot.tag2('kor-search', '\n  <h1>Search</h1>\n\n  <form class="form">\n    <div class="row">\n      <div class="col-md-3">\n        <div class="form-group">\n          <input type="text" name="terms" placeholder="fulltext search ..." class="form-control" id="kor-search-form-terms" onchange="{form_to_url}" value="{params.terms}">\n        </div>\n      </div>\n    </div>\n    <div class="row">\n      <div class="col-md-12 collections">\n        <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button>\n\n        <div class="checkbox-inline" each="{collection in collections}">\n          <label>\n            <input type="checkbox" value="{collection.id}" __checked="{parent.is_collection_checked(collection)}" onchange="{parent.form_to_url}">\n            {collection.name}\n          </label>\n        </div>\n      </div>\n    </div>\n\n    <div class="row">\n      <div class="col-md-12 kinds">\n        <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button>\n\n        <div class="checkbox-inline" each="{kind in kinds}">\n          <label>\n            <input type="checkbox" value="{kind.id}" __checked="{parent.is_kind_checked(kind)}" onchange="{parent.form_to_url}">\n            {kind.plural_name}\n          </label>\n        </div>\n      </div>\n    </div>\n\n    <div class="row">\n      <div class="col-md-3 kinds" each="{field in fields}">\n        <div class="form-group">\n          <input type="text" name="{field.name}" placeholder="{field.search_label}" class="kor-dataset-field form-control" id="kor-search-form-dataset-{field.name}" onchange="{parent.form_to_url}" value="{parent.params.dataset[field.name]}">\n        </div>\n      </div>\n    </div>\n  </form>\n', 'kor-search .allnone, [data-is=\'kor-search\'] .allnone { margin-right: 1rem; margin-top: -3px; }', '', function(opts) {
var self;

self = this;

window.x = this;

self.params = {};

self.on('mount', function() {
  $.ajax({
    type: 'get',
    url: kor.url + "/kinds",
    success: function(data) {
      self.kinds = data;
      return self.update();
    }
  });
  $.ajax({
    type: 'get',
    url: kor.url + "/collections",
    success: function(data) {
      self.collections = data;
      return self.update();
    }
  });
  self.url_to_params();
  return self.update();
});

self.kor.bus.on('query.data', function() {
  self.url_to_params();
  return self.update();
});

self.is_kind_checked = function(kind) {
  return self.params['kind_ids'] === void 0 || self.params['kind_ids'].indexOf(kind.id) > -1;
};

self.is_collection_checked = function(collection) {
  return self.params['collection_ids'] === void 0 || self.params['collection_ids'].indexOf(collection.id) > -1;
};

self.url_to_params = function() {
  self.params = self.kor.routing.state.get();
  self.load_fields();
  return self.update();
};

self.form_to_url = function() {
  var cb, collection_ids, dataset, i, j, kind_ids, len, len1, ref, ref1;
  kind_ids = [];
  ref = $(self.root).find('.kinds input[type=checkbox]:checked');
  for (i = 0, len = ref.length; i < len; i++) {
    cb = ref[i];
    kind_ids.push(parseInt($(cb).val()));
  }
  collection_ids = [];
  ref1 = $(self.root).find('.collections input[type=checkbox]:checked');
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    cb = ref1[j];
    collection_ids.push(parseInt($(cb).val()));
  }
  dataset = {};
  return self.kor.routing.state.update({
    terms: $(x.root).find('[name=terms]').val(),
    collection_ids: collection_ids,
    kind_ids: kind_ids
  });
};

self.load_fields = function() {
  var id;
  if (self.params.kind_ids.length === 1) {
    id = self.params.kind_ids[0];
    return $.ajax({
      type: 'get',
      url: kor.url + "/kinds/" + id + "/fields",
      success: function(data) {
        console.log(data);
        self.fields = data;
        return self.update();
      }
    });
  } else {
    return self.fields = [];
  }
};

self.allnone = function(event) {
  var box, boxes, i, len;
  event.preventDefault();
  boxes = $(event.target).parent().find('input[type=checkbox]');
  for (i = 0, len = boxes.length; i < len; i++) {
    box = boxes[i];
    if (!$(box).is(':checked')) {
      boxes.prop('checked', true);
      self.form_to_url();
      return;
    }
  }
  boxes.prop('checked', null);
  return self.form_to_url();
};
});
riot.tag2('kor-welcome', '  <h2>Welcome</h2>\n', '', '', function(opts) {
});