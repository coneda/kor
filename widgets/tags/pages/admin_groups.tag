<kor-admin-groups>
  <div class="kor-content-box">
    <a
      if={!opts.type && isAuthorityGroupAdmin()}
      href="{baseUrl()}/new"
      class="pull-right"
      title={t('objects.new', {interpolations: {o: t('activerecord.models.authority_group')}})}
    ><i class="fa fa-plus-square"></i></a>
    <h1>
      {tcap('activerecord.models.authority_group', {count: 'other'})}
    </h1>

    <table if={data && data.total > 0}>
      <thead>
        <tr>
          <th>{tcap('activerecord.attributes.authority_group.name')}</th>
          <th if={isAuthorityGroupAdmin()}></th>
        </tr>
      </thead>
      <tbody>
        <tr each={group in data.records}>
          <td>
            <a
              href="#/groups/admin/{group.id}"
            >{group.name}</td>
          <td class="right nowrap" if={isAuthorityGroupAdmin()}>
            <a
              href="{baseUrl()}/{group.id}/edit"
              title={t('verbs.edit')}
            ><i class="fa fa-pencil"></i></a>
            <a
              href="{baseUrl()}/{group.id}"
              title={t('verbs.delete')}
              onclick={onDeleteClicked}
            ><i class="fa fa-trash"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      tag.title(tag.tcap('activerecord.models.authority_group', {count: 'other'}))
      fetch();
    })

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