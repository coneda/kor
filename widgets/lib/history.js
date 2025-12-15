wApp.entityHistory = {
  add: function(id) {
    var ids = wApp.entityHistory.ids();
    ids.unshift(id);
    ids = ids.slice(0, 30);
    Lockr.set('entity-history', ids);
  },
  ids: function() {
    return Lockr.get('entity-history') || [];
  },
  reset: function() {
    Lockr.rm('entity-history');
  },
  setup: function() {
    wApp.bus.on('logout', function() {
      wApp.entityHistory.reset()
    })
  }
}
