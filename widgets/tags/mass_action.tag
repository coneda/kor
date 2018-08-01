<kor-mass-action>

  <h1>{tcap('nouns.action')}</h1>

  <div class="amount">
    {opts.ids.length} {t('activerecord.models.entity', {count: 'other'})}
  </div>

  <hr />

  <a class="action" onclick={merge}>{tcap('clipboard_actions.merge')}</a>
  <a class="action" onclick={massRelate}>{tcap('clipboard_actions.mass_relate')}</a>
  <a class="action" onclick={massDelete}>{tcap('clipboard_actions.mass_delete')}</a>
  <a class="action" onclick={addToAuthorityGroup}>{tcap('clipboard_actions.add_to_authority_group')}</a>
  <a class="action" onclick={addToUserGroup}>{tcap('clipboard_actions.add_to_user_group')}</a>
  <a class="action" onclick={moveToCollection}>{tcap('clipboard_actions.move_to_collection')}</a>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.merge = function() {
      
    }

    tag.massRelate = function() {
      
    }

    tag.massDelete = function() {
      if (wApp.utils.confirm()) {
        var data = {ids: wApp.clipboard.subSelection()};
        Zepto.ajax({
          type: 'DELETE',
          url: '/tools/mass_delete',
          data: JSON.stringify(data),
          success: function(data) {
            var ids = wApp.clipboard.subSelection();
            for (var i = 0; i < ids.length; i++) {
              wApp.clipboard.remove(ids[i]);
            }
            notify();
          }
        })
      }
    }

    tag.addToAuthorityGroup = function() {
      
    }

    tag.addToUserGroup = function() {
      var ids = wApp.clipboard.subSelection();
      wApp.bus.trigger('modal', 'kor-add-to-user-group', {
        id: ids
      })
    }

    tag.moveToCollection = function() {
      
    }

    var notify = function() {
      var h = tag.opts.onActionSuccess;
      if (h) {h();}
    }

  </script>
</kor-mass-action>