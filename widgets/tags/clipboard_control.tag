<kor-clipboard-control>
  <a
    onclick={toggle}
    if={!isGuest() && !isStatic()}
    href="#/entities/{opts.entity.id}/to_clipboard"
    class="to-clipboard"
    title={t('add_to_clipboard')}
  >
    <i class="fa fa-clipboard {kor-glow: isIncluded()}"></i>
  </a>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);

  tag.on('mount', function() {
    wApp.bus.on('clipboard-changed', tag.update);
  });

  tag.on('unmount', function() {
    wApp.bus.off('clipboard-changed', tag.update);
  });

  tag.isIncluded = function() {
    return wApp.clipboard.includes(tag.opts.entity.id);
  };

  tag.isSelected = function() {
    return wApp.clipboard.selected(tag.opts.entity.id);
  };

  tag.toggle = function(event) {
    event.preventDefault();
    if (tag.isIncluded()) {
      wApp.clipboard.remove(tag.opts.entity.id);
      wApp.bus.trigger('message', 'notice', tag.t('objects.unmarked_entity_success'));
    } else {
      if (wApp.clipboard.ids().length <= 500) {
        wApp.clipboard.add(tag.opts.entity.id);
        wApp.bus.trigger('message', 'notice', tag.t('objects.marked_entity_success'));
      } else {
        wApp.bus.trigger('message', 'error', tag.t('messages.clipboard_too_many_elements'));
      }
    }
    tag.update();
  };

  tag.toggleSelection = function(event) {
    event.preventDefault();
    if (!tag.isSelected()) {
      wApp.clipboard.select(tag.opts.entity.id);
      wApp.bus.trigger('message', 'notice', tag.t('objects.marked_as_current_success'));
      tag.update();
    }
  };
</script>

</kor-clipboard-control>
