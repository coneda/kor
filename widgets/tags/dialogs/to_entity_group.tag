<kor-to-entity-group>
  <div class="kor-content-box">
    <h1>{title()}</h1>

    <form onsubmit={submit}>
      <kor-entity-group-selector
        type={opts.type}
        ref="group"
      />

      <kor-input type="submit" />
    </form>

    {opts.type}

    <a
      if={opts.type == 'authority'}
      href="#/groups/categories/admin/new"
      onclick={add}
    >{t('create_new')}</a>

    <a
      if={opts.type == 'user'}
      href="#/groups/user/new"
      onclick={add}
    >{t('create_new')}</a>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.title = function() {
      return tag.tcap('clipboard_actions.add_to_' + opts.type + '_group');
    }

    tag.submit = function(event) {
      event.preventDefault();
      Zepto.ajax({
        type: 'POST',
        url: '/' + tag.opts.type + '_groups/' + tag.refs.group.value() + '/add',
        data: JSON.stringify({
          entity_ids: tag.opts.entityIds
        }),
        success: function(data) {
          tag.opts.modal.trigger('close');
        }
      });
    }
  </script>
</kor-to-entity-group>