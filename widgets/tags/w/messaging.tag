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
    wApp.bus.on('request-complete', ajaxCompleteHandler);
  });

  // On unmount, unbind ajaxComplete handler
  self.on('unmount', function() {
    wApp.bus.off('request-complete', ajaxCompleteHandler);
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
  var ajaxCompleteHandler = function(response) {
    try {
      var data = response.data;

      if (data.message && !response.noMessaging) {
        var type = (response.status >= 200 && response.status < 300) ? 'notice' : 'error';
        wApp.bus.trigger('message', type, data.message);
      }

      if (data.notice && !response.noMessaging) {
        wApp.bus.trigger('message', 'notice', data.notice);
      }

      if (data.code) {
        wApp.bus.trigger('server-code', data.code);
      }

    } catch (e) {
      // TODO: should this be console.error?
      console.log(e, response);
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

