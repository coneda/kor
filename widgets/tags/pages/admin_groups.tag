<kor-admin-groups>
  <div class="kor-content-box">
    <a
      if={!opts.type}
      href="{baseUrl()}/new"
      class="pull-right"
      title={t('objects.new', {interpolations: {o: t('activerecord.models.authority_group')}})}
    ><i class="plus"></i></a>
    <h1>
      {tcap('activerecord.models.authority_group', {count: 'other'})}
    </h1>

    <table if={data && data.total > 0}>
      <thead>
        <tr>
          <th>{tcap('activerecord.attributes.authority_group.name')}</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr each={group in data.records}>
          <td>
            <a
              href="#/groups/admin/{group.id}"
            >{group.name}</td>
          <td class="right nowrap" if={isAdmin()}>
            <a
              href="{baseUrl()}/{group.id}/edit"
              title={t('verbs.edit')}
            ><i class="pen"></i></a>
            <a
              href="{baseUrl()}/{group.id}"
              title={t('verbs.delete')}
              onclick={onDeleteClicked}
            ><i class="x"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
    })

    tag.isAdmin = function() {
      return wApp.session.current.user.authority_group_admin;
    }

    tag.baseUrl = function() {
      if (tag.opts.categoryId) {
        return '#/groups/categories/' + tag.opts.categoryId + '/admin';
      }

      return '#/groups/categories/admin';
    }

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      if (wApp.utils.confirm())
        destroy(event.item.group.id);
    }

    var destroy = function(id) {
      Zepto.ajax({
        type: 'DELETE',
        url: '/authority_groups/' + id,
        success: fetch
      })
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/authority_groups',
        data: {authority_group_category_id: tag.opts.categoryId},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>
  
</kor-admin-groups>