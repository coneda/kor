# TODO: probably not needed anymore
wApp.bubbling_events = []

riot.mixin 'bubble', {
  init: ->
    tag = this

    for event_name in wApp.bubbling_events
      tag.on event_name, (args...) ->
        tag.parent.trigger(event_name, args...) if tag.parent
}
