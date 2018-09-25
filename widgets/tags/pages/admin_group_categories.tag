<kor-admin-group-categories>
  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <a
        if={!opts.type}
        href="#/groups/admin/category/new"
        class="pull-right"
        title={t('objects.new', {interpolations: {o: t('activerecord.models.authority_group_category')}})}
      ><i class="plus"></i></a>
      <h1>
        {tcap('activerecord.models.authority_group_category', {count: 'other'})}
      </h1>

      <table if={data && data.total > 0}>
        <thead>
          <tr>
            <th>{tcap('activerecord.attributes.authority_group_category.name')}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr each={category in data.records}>
            <td>
              <a
                href="#/groups/admin?category={category.id}"
              >{category.name}</td>
            <td class="right nowrap" if={isAdmin()}>
              <a
                href="#/groups/admin/category/{category.id}/edit"
                title={t('verbs.edit')}
              ><i class="pen"></i></a>
              <a
                href="#/groups/admin/category/{category.id}"
                title={t('verbs.edit')}
                onclick={onDeleteClicked}
              ><i class="x"></i></a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="kor-layout-left kor-layout-large">
    <kor-admin-groups />
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
      wApp.bus.on('routing:query', fetch);
    })

    tag.on('unmount', function() {
      wApp.bus.off('routing:query', fetch);
    })

    tag.isAdmin = function() {
      return wApp.session.current.user.authority_group_admin;
    }

    var fetch = function() {
      var id = wApp.routing.query()['category'];

      Zepto.ajax({
        url: '/authority_group_categories',
        data: {root_id: id},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>
</kor-admin-group-categories>