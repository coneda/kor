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
      Zepto(document).on 'ajaxComplete', ajaxCompleteHandler

    self.on 'unmount', ->
      Zepto(document).off 'ajaxComplete', ajaxCompleteHandler

    wApp.bus.on 'message', (type, message) -> 
      self.messages.push {
        type: type,
        content: message
      }
      window.setTimeout(self.drop, self.opts.duration || 5000)
      self.update()

    ajaxCompleteHandler = (event, request, options) ->
      contentType = request.getResponseHeader('content-type')

      if contentType.match(/^application\/json/) && request.response
        try
          data = JSON.parse(request.response)
          
          if data.message
            type = if request.status >= 200 && request.status < 300 then 'notice' else 'error'
            wApp.bus.trigger 'message', type, data.message
        catch e
          # console.log request

    self.drop = ->
      self.messages.shift()
      self.update()
    self.error = (message) -> message.type == 'error'
    self.notice = (message) -> message.type == 'notice'
  </script>

</w-messaging>