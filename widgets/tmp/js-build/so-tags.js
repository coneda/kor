riot.tag2('kor-entity', '\n  <div class="auth" if="{!authorized}">\n    <strong>Info</strong>\n\n    <p>\n      It seems you are not allowed to see this content. Please\n      <a href="{login_url()}">login</a> to the kor installation first.\n    </p>\n  </div>\n\n  <a href="{url()}" if="{authorized}" target="_blank">\n    <img if="{data.medium}" riot-src="{image_url()}">\n    <div if="{!data.medium}">\n      <h3>{data.display_name}</h3>\n      <em if="{include(\'kind\')}">\n        {data.kind_name}\n        <span show="{data.subtype}">({data.subtype})</span>\n      </em>\n    </div>\n  </a>\n', '.kor { font-family: verdana; font-size: 11px; background-color: #1e1e1e; color: #bbbbbb; } .kor a { text-decoration: underline; color: #bbbbbb; } kor-entity.kor-style, [data-is=kor-entity].kor-style { display: inline-block; vertical-align: bottom; box-sizing: border-box; width: 200px; max-height: 200px; padding: 0.5rem; } kor-entity.kor-style > a, [data-is=kor-entity].kor-style > a { display: block; text-decoration: none; } kor-entity.kor-style h3, [data-is=kor-entity].kor-style h3 { margin: 0px; color: white; } kor-entity.kor-style img, [data-is=kor-entity].kor-style img { display: block; max-width: 100%; max-height: 160px; }', 'class="{\'kor-style\': opts.korStyle, \'kor\': opts.korStyle}"', function(opts) {
var self;

self = this;

self.authorized = true;

self.on('mount', function() {
  var base;
  if (self.opts.id) {
    base = $('script[kor-url]').attr('kor-url') || "";
    return $.ajax({
      type: 'get',
      url: base + "/entities/" + self.opts.id,
      data: {
        include: 'all'
      },
      dataType: 'json',
      beforeSend: function(xhr) {
        return xhr.withCredentials = true;
      },
      success: function(data) {
        self.data = data;
        return self.update();
      },
      error: function(request) {
        self.data = {};
        if (request.status === 403) {
          self.authorized = false;
          return self.update();
        }
      }
    });
  } else {
    return raise("this widget requires an id");
  }
});

self.login_url = function() {
  var base, return_to;
  base = $('script[kor-url]').attr('kor-url') || "";
  return_to = document.location.href;
  return base + "/login?return_to=" + return_to;
};

self.image_size = function() {
  return self.opts.korImageSize || 'preview';
};

self.image_url = function() {
  var base, size;
  base = $('script[kor-url]').attr('kor-url') || "";
  size = self.image_size();
  return "" + base + self.data.medium.url[size];
};

self.include = function(what) {
  var includes;
  includes = (self.opts.korInclude || "").split(/\s+/);
  return includes.indexOf(what) !== -1;
};

self.url = function() {
  var base;
  base = $('[kor-url]').attr('kor-url') || "";
  return base + "/blaze#/entities/" + self.data.id;
};

self.human_size = function() {
  var size;
  size = self.data.medium.file_size / 1024.0 / 1024.0;
  return Math.floor(size * 100) / 100;
};
});