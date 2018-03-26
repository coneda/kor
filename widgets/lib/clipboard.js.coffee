wApp.clipboard = {
  add: (id) ->
    Lockr.sadd('clipboard', id)
    wApp.bus.trigger 'clipboard-changed'
  remove: (id) ->
    Lockr.srem('clipboard', id)
    wApp.bus.trigger 'clipboard-changed'
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
  ids: -> Lockr.smembers('clipboard')
  setup: ->
    wApp.bus.on 'logout', -> wApp.clipboard.reset()
}
