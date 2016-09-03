<w-messaging>

  <div
    each={message in messages}
    class="message {'error': error(message), 'notice': notice(message)}"
  >
    <i show={notice(message)} class="fa fa-warning"></i>
    <i show={error(message)} class="fa fa-info-circle"></i>
    {message.content}
  </div>

  <style type="text/scss">
    @import "widgets/styles/vars.scss";

    w-messaging, [data-is=w-messaging] {
      position: fixed;
      right: 0px;
      top: 0px;

      .message {
        padding: 1rem;
        margin-bottom: 1px;
      }

      .error {
        background-color: $color-secondary-2-4;
        color: white;
      }

      .notice {
        background-color: $color-secondary-1-4;
        color: white;
      }
    }
  </style>

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