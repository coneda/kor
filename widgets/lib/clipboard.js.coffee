wApp.clipboard = {
  add: (id) ->
    Lockr.sadd('clipboard', id)
    wApp.bus.trigger 'clipboard-changed'
  remove: (id) ->
    Lockr.srem('clipboard', id)
    wApp.bus.trigger 'clipboard-changed'
    if wApp.clipboard.subSelected(id)
      wApp.clipboard.unSubSelect(id)
  includes: (id) -> Lockr.sismember('clipboard', id)
  select: (id) ->
    Lockr.set('selection', id)
    wApp.bus.trigger 'clipboard-changed'
  unselect: ->
    Lockr.rm('selection')
    wApp.bus.trigger 'clipboard-changed'
  selected: (id) -> wApp.clipboard.selection() == id
  selection: -> Lockr.get('selection')
  reset: ->
    Lockr.rm('clipboard')
    wApp.clipboard.unselect()
    wApp.clipboard.resetSubSelection()
  ids: -> Lockr.smembers('clipboard')
  setup: ->
    wApp.bus.on 'logout', -> wApp.clipboard.reset()

  subSelect: (id) ->
    Lockr.sadd('clipboard-subselection', id)
    wApp.bus.trigger 'clipboard-subselection-changed'
  unSubSelect: (id) ->
    Lockr.srem('clipboard-subselection', id)
    wApp.bus.trigger 'clipboard-subselection-changed'
  resetSubSelection: ->
    Lockr.rm('clipboard-subselection')
    wApp.bus.trigger 'clipboard-subselection-changed'
  subSelected: (id) ->
    Lockr.sismember('clipboard-subselection', id)
  subSelection: ->
    Lockr.smembers('clipboard-subselection')
  subSelectAll: ->
    for id in wApp.clipboard.ids()
      wApp.clipboard.subSelect(id)
}
