wApp.clipboard = {
  add: function (id) {
    Lockr.sadd('clipboard', id)
    wApp.bus.trigger('clipboard-changed')
  },
  remove: function (id) {
    Lockr.srem('clipboard', id)
    wApp.bus.trigger('clipboard-changed')
    if (wApp.clipboard.subSelected(id)) {
      wApp.clipboard.unSubSelect(id)
    }
  },
  includes: function (id) {
    return Lockr.sismember('clipboard', id)
  },
  select: function (id) {
    Lockr.set('selection', id)
    wApp.bus.trigger('clipboard-changed')
  },
  unselect: function () {
    Lockr.rm('selection')
    wApp.bus.trigger('clipboard-changed')
  },
  selected: function (id) {
    return wApp.clipboard.selection() === id
  },
  selection: function () {
    return Lockr.get('selection')
  },
  reset: function () {
    Lockr.rm('clipboard')
    wApp.clipboard.unselect()
    wApp.clipboard.resetSubSelection()
  },
  ids: function () {
    return Lockr.smembers('clipboard')
  },
  setup: function () {
    wApp.bus.on('logout', function () {
      wApp.clipboard.reset()
    })
  },
  subSelect: function (id) {
    Lockr.sadd('clipboard-subselection', id)
    wApp.bus.trigger('clipboard-subselection-changed')
  },
  unSubSelect: function (id) {
    Lockr.srem('clipboard-subselection', id)
    wApp.bus.trigger('clipboard-subselection-changed')
  },
  resetSubSelection: function () {
    Lockr.rm('clipboard-subselection')
    wApp.bus.trigger('clipboard-subselection-changed')
  },
  subSelected: function (id) {
    return Lockr.sismember('clipboard-subselection', id)
  },
  subSelection: function () {
    return Lockr.smembers('clipboard-subselection')
  },
  subSelectAll: function () {
    var ids = wApp.clipboard.ids()
    for (var i = 0; i < ids.length; i++) {
      wApp.clipboard.subSelect(ids[i])
    }
  },
  checkEntityExistence: function () {
    var ids = wApp.clipboard.ids().concat(wApp.clipboard.subSelection())
    return Zepto.ajax({
      type: 'POST',
      url: '/entities/existence',
      data: JSON.stringify({ ids: ids }),
      success: function (data) {
        for (var id in data) {
          if (!data[id]) {
            wApp.clipboard.remove(parseInt(id))
          }
        }
      }
    })
  }
}
