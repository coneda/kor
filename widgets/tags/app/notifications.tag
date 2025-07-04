<kor-notifications>

  <ul>
    <li
      each={data in messages}
      class="bg-warning {kor-fade-animation: data.remove}"
      onanimationend={parent.animend}
    >
      <i class="glyphicon glyphicon-exclamation-sign"></i>
      {data.message}
    </li>
  </ul>

<script type="text/javascript">
  var tag = this;
  tag.messages = [];
  tag.history = [];

  // Handle animation end: move message to history and remove from messages
  tag.animend = function(event) {
    var i = tag.messages.indexOf(event.item.data);
    tag.history.push(tag.messages[i]);
    tag.messages.splice(i, 1);
    tag.update();
  };

  // Add a fading notification message
  var fading = function(data) {
    tag.messages.push(data);
    tag.update();

    setTimeout(function() {
      data.remove = true;
      tag.update();
    }, 5000);
  };

  // Listen for 'notify' events and handle default type with fading
  kor.bus.on('notify', function(data) {
    var type = data.type || 'default';
    if (type === 'default') fading(data);
    tag.update();
  });
</script>

</kor-notifications>