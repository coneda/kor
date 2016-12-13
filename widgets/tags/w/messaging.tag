<w-messaging>

  <div
    each={message in messages}
    class="message {'error': error(message), 'notice': notice(message)}"
  >
    <i show={notice(message)} class="fa fa-warning"></i>
    <i show={error(message)} class="fa fa-info-circle"></i>
    {message.content}
  </div>

  <script type="text/coffee">
    tag = this

    Zepto(document).on 'ajaxComplete', (event, request, options) ->
      try
        data = request.responseJSON || JSON.parse(request.response)
        # console.log data
        if data.message
          type = if request.status >= 200 && request.status < 300 then 'notice' else 'error'
          wApp.bus.trigger 'message', type, data.message
      catch e
        console.log e

    tag.on 'mount', ->
      tag.messages = []
    wApp.bus.on 'message', (type, message) -> 
      tag.messages.push {
        type: type,
        content: message
      }
      window.setTimeout(tag.drop, tag.opts.duration || 5000)
      tag.update()

    tag.drop = ->
      tag.messages.shift()
      tag.update()
    tag.error = (message) -> message.type == 'error'
    tag.notice = (message) -> message.type == 'notice'
  </script>

</w-messaging>