<kor-sub-menu>

  <a href="#" onclick={toggle}>{opts.label}</a>
  <div class="content" show={visible()}>
    <yield />
  </div>

<script type="text/javascript">
  var tag = this;

  // Check if the submenu is visible based on stored toggles
  tag.visible = function() {
    var toggles = Lockr.get('toggles') || {};
    return toggles[tag.opts.menuId];
  };

  // Toggle the submenu visibility and persist the state
  tag.toggle = function(event) {
    event.preventDefault();
    var data = Lockr.get('toggles') || {};
    data[tag.opts.menuId] = !data[tag.opts.menuId];
    Lockr.set('toggles', data);
  };
</script>
</kor-sub-menu>