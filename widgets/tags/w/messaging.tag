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

    $(document).on 'ajaxComplete', (event, request, options) ->
      try
        data = JSON.parse(request.response)
        # console.log data
        if data.message
          type = if request.status >= 200 && request.status < 300 then 'notice' else 'error'
          wApp.bus.trigger 'message', type, data.message
      catch e
        console.log e

    self.on 'mount', -> self.messages = []
    wApp.bus.on 'message', (type, message) -> 
      self.messages.push {
        type: type,
        content: message
      }
      window.setTimeout(self.drop, self.opts.duration || 5000)
      self.update()

    self.drop = ->
      self.messages.shift()
      self.update()
    self.error = (message) -> message.type == 'error'
    self.notice = (message) -> message.type == 'notice'
  </script>

</w-messaging>