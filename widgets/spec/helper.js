var spec = {
  logPage: function() {console.log(Zepto('html').html())},
  ensureTagElement: function() {
    if (Zepto('context').length > 0) {
      Zepto('context').remove();
    }
    var element = Zepto('<context><target></target></context>');
    Zepto('body').prepend(element);
  },
  unmount: function(tag) {if (tag) tag.unmount(true)},
  mount: function(tagName, opts) {
    if (!opts) {opts = {}}
    var result = riot.mount('target', tagName, opts)[0];
    return result;
  }
}
