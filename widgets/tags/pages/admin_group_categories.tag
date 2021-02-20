<kor-admin-group-categories>
  <kor-help-button key="authority_groups" />

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <a
        if={!opts.type && isAuthorityGroupAdmin()}
        href={newCategoryUrl()}
        class="pull-right"
        title={t('objects.new', {interpolations: {o: t('activerecord.models.authority_group_category')}})}
      ><i class="fa fa-plus-square"></i></a>
      <h1>
        {tcap('activerecord.models.authority_group_category', {count: 'other'})}
      </h1>

      <p class="ancestry" if={parentCategory}>
        <a href="#/groups/categories">{t('nouns.top_level')}</a>
        <virtual each={a in parentCategory.ancestors}>
          <span class="separator">»</span>
          <a href="#/groups/categories/{a.id}">{a.name}</a>
        </virtual>
        <span class="separator">»</span>
        <span>{parentCategory.name}</span>
      </p>

      <table if={data && data.total > 0}>
        <thead>
          <tr>
            <th>{tcap('activerecord.attributes.authority_group_category.name')}</th>
            <th if={isAuthorityGroupAdmin()}></th>
          </tr>
        </thead>
        <tbody>
          <tr each={category in data.records}>
            <td>
              <a
                href="#/groups/categories/{category.id}"
              >{category.name}</td>
            <td class="right nowrap" if={isAuthorityGroupAdmin()}>
              <a
                href="#/groups/categories/{category.id}/edit"
                title={t('verbs.edit')}
              ><i class="fa fa-pencil"></i></a>
              <a
                href="#/groups/categories/{category.id}"
                title={t('verbs.delete')}
                onclick={onDeleteClicked}
              ><i class="fa fa-trash"></i></a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <kor-admin-groups category-id={opts.parentId} />
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      if (tag.opts.parentId) {fetchParent();}
      fetch();
    })

    tag.newCategoryUrl = function() {
      if (tag.opts.parentId) {
        return '#/groups/categories/' + tag.opts.parentId + '/new'
      }

      return '#/groups/categories/new'
    }

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      if (wApp.utils.confirm())
        destroy(event.item.category.id);
    }

    var destroy = function(id) {
      Zepto.ajax({
        type: 'DELETE',
        url: '/authority_group_categories/' + id,
        success: fetch
      })
    }

    var fetchParent = function() {
      Zepto.ajax({
        url: '/authority_group_categories/' + tag.opts.parentId,
        data: {include: 'ancestors'},
        success: function(data) {
          tag.parentCategory = data;
          tag.update();
        }
      })
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/authority_group_categories',
        data: {parent_id: tag.opts.parentId, per_page: 'max'},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>
</kor-admin-group-categories>