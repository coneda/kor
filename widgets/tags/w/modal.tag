<w-modal show={active}>

  <div class="receiver" ref="receiver"></div>

<script type="text/javascript">
  let tag = this;
  tag.active = false;
  tag.mountedTag = null;

  // Listen for 'modal' event to mount a tag inside the modal
  wApp.bus.on('modal', function(tagName, opts) {
    opts = opts || {};
    // opts.modal = tagName
    opts.modal = tag;
    tag.mountedTag = riot.mount(tag.refs.receiver, tagName, opts)[0];
    tag.active = true;
    tag.update();
  });

  // Close modal on Escape key
  Zepto(document).on('keydown', function(event) {
    if (tag.active && event.key === 'Escape') {
      tag.trigger('close');
    }
  });

  // Close modal when clicking on the modal background
  tag.on('mount', function() {
    Zepto(tag.root).on('click', function(event) {
      if (tag.active && event.target === tag.root) {
        tag.trigger('close');
      }
    });
  });

  // Handle modal close event
  tag.on('close', function() {
    if (tag.active) {
      tag.active = false;
      tag.mountedTag.unmount(true);
      tag.update();
    }
  });
</script>

</w-modal>
