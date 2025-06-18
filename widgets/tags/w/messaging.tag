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
    self = this

    self.on 'mount', ->
      self.messages = []
      wApp.bus.on('request-complete', ajaxCompleteHandler)

    self.on 'unmount', ->
      wApp.bus.off('request-complete', ajaxCompleteHandler)

    wApp.bus.on 'message', (type, message) ->
      self.messages.push {
        type: type,
        content: message
      }
      window.setTimeout(self.drop, duration())
      self.update()

    duration = -> 3000

    ajaxCompleteHandler = (response) ->
      try
        data = response.data

        if data.message && !request.noMessaging
          type = if request.status >= 200 && request.status < 300 then 'notice' else 'error'
          wApp.bus.trigger 'message', type, data.message

        if data.notice && !request.noMessaging
          wApp.bus.trigger 'message', 'notice', data.notice

        if data.code
          wApp.bus.trigger 'server-code', data.code

      catch e
        # TODO: should this be console.error?
        console.log e, request

    self.drop = ->
      self.messages.shift()
      self.update()
    self.error = (message) -> message.type == 'error'
    self.notice = (message) -> message.type == 'notice'
  </script>
</w-messaging>
