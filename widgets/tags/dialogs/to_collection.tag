<kor-to-collection>
  <div class="kor-content-box">
    <h1>{title()}</h1>

    <form onsubmit={submit}>
      <kor-collection-selector ref="collection" />

      <kor-input type="submit" />
    </form>
  </div>

  <script type="text/javascript">
    let tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.title = function() {
      return tag.tcap('clipboard_actions.move_to_collection');
    }

    tag.submit = function(event) {
      event.preventDefault();
      Zepto.ajax({
        type: 'PATCH',
        url: '/collections/' + tag.refs.collection.value() + '/entities',
        data: JSON.stringify({
          entity_ids: tag.opts.entityIds
        }),
        success: function(data) {
          tag.opts.modal.trigger('close');
        }
      });
    }
  </script>
</kor-to-collection>
