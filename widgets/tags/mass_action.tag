<kor-mass-action>

  <h1>{tcap('nouns.action')}</h1>

  <div class="amount">
    {opts.ids.length} {t('activerecord.models.entity', {count: 'other'})}
  </div>

  <div class="hr"></div>

  <virtual if={opts.ids.length}>
    <a
      if={allowedTo('create') && allowedTo('delete')}
      class="action"
      href="#"
      onclick={merge}
    >{tcap('clipboard_actions.merge')}</a>

    <a
      if={allowedTo('edit')}
      class="action"
      href="#"
      onclick={massRelate}
    >{tcap('clipboard_actions.mass_relate')}</a>

    <a
      if={allowedTo('delete')}
      class="action"
      href="#"
      onclick={massDelete}
    >{tcap('clipboard_actions.mass_delete')}</a>

    <a
      if={session().user.authority_group_admin}
      class="action"
      href="#"
      onclick={addToAuthorityGroup}
    >{tcap('clipboard_actions.add_to_authority_group')}</a>

    <a
      class="action"
      href="#"
      onclick={addToUserGroup}
    >{tcap('clipboard_actions.add_to_user_group')}</a>

    <a
      class="action"
      href="#"
      onclick={moveToCollection}
    >{tcap('clipboard_actions.move_to_collection')}</a>
  </virtual>


  <script type="text/javascript">
    let tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.i18n);

    tag.merge = function(event) {
      event.preventDefault();
      wApp.bus.trigger('modal', 'kor-entity-merger', {ids: tag.opts.ids});
    }

    tag.massRelate = function(event) {
      event.preventDefault();

      wApp.bus.trigger('modal', 'kor-mass-relate', {
        ids: wApp.clipboard.subSelection()
      })
    }

    tag.massDelete = function(event) {
      event.preventDefault();

      if (wApp.utils.confirm()) {
        var data = {ids: wApp.clipboard.subSelection()};
        Zepto.ajax({
          type: 'DELETE',
          url: '/entities/mass_destroy',
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

    var addToEntityGroup = function(type) {
      wApp.bus.trigger('modal', 'kor-to-entity-group', {
        type: type,
        entityIds: wApp.clipboard.subSelection()
      })
    }

    tag.addToAuthorityGroup = function(event) {
      event.preventDefault();
      addToEntityGroup('authority');
    }

    tag.addToUserGroup = function(event) {
      event.preventDefault();
      addToEntityGroup('user');
    }

    tag.moveToCollection = function(event) {
      event.preventDefault();

      wApp.bus.trigger('modal', 'kor-to-collection', {
        entityIds: wApp.clipboard.subSelection()
      })
    }

    var notify = function() {
      var h = tag.opts.onActionSuccess;
      if (h) {h();}
    }

  </script>
</kor-mass-action>