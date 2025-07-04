<kor-menu-fix>

<script type="text/javascript">
  var tag = this;

  // On mount, listen for 'kinds-changed' event to fix the menu
  tag.on('mount', function() {
    wApp.bus.on('kinds-changed', fixMenu);
  });

  // On unmount, remove the event listener
  tag.on('unmount', function() {
    wApp.bus.off('kinds-changed', fixMenu);
  });

  // Fetch active kinds and update the kind select menu
  var fixMenu = function() {
    Zepto.ajax({
      url: '/kinds',
      data: { only_active: true },
      success: function(data) {
        var select = Zepto('#new_entity_kind_id');
        var placeholder = select.find('option:first-child').remove();
        select.find('option').remove();
        select.append(placeholder);
        for (var i = 0; i < data.records.length; i++) {
          var kind = data.records[i];
          select.append('<option value="' + kind.id + '">' + kind.name + '</option>');
        }
      }
    });
  };
  </script>
  
</kor-menu-fix>