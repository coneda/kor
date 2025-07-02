<w-messaging>
  <div
    each={message in messages}
    class="message {'error': error(message), 'notice': notice(message)}"
  >
    <i show={notice(message)} class="fa fa-warning"></i>
    <i show={error(message)} class="fa fa-info-circle"></i>
    {message.content}
  </div>

<script type="text/javascript">
  var self = this;

  // On mount, initialize messages and bind ajaxComplete handler
  self.on('mount', function() {
    self.messages = [];
    Zepto(document).on('ajaxComplete', ajaxCompleteHandler);
  });

  // On unmount, unbind ajaxComplete handler
  self.on('unmount', function() {
    Zepto(document).off('ajaxComplete', ajaxCompleteHandler);
  });

  // Listen for message events and add them to the messages list
  wApp.bus.on('message', function(type, message) {
    self.messages.push({
      type: type,
      content: message
    });
    window.setTimeout(self.drop, duration());
    self.update();
  });

  // Duration for message display (ms)
  var duration = function() {
    return 3000;
  };

  // Handle ajaxComplete events and trigger messages if needed
  var ajaxCompleteHandler = function(event, request, options) {
    var contentType = request.getResponseHeader && request.getResponseHeader('content-type');
    if (contentType && contentType.match(/^application\/json/) && request.response) {
      try {
        var data = JSON.parse(request.response);

        if (data.message && !request.noMessaging) {
          var type = (request.status >= 200 && request.status < 300) ? 'notice' : 'error';
          wApp.bus.trigger('message', type, data.message);
        }

        if (data.notice && !request.noMessaging) {
          wApp.bus.trigger('message', 'notice', data.notice);
        }

        if (data.code) {
          wApp.bus.trigger('server-code', data.code);
        }
      } catch (e) {
        console.log(e, request); // TODO: Consider using console.error
      }
    }
  };

  // Remove the oldest message and update UI
  self.drop = function() {
    self.messages.shift();
    self.update();
  };

  // Check if a message is an error
  self.error = function(message) {
    return message.type === 'error';
  };

  // Check if a message is a notice
  self.notice = function(message) {
    return message.type === 'notice';
  };
</script>

</w-messaging>