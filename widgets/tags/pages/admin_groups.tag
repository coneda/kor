<kor-admin-groups>
  <div class="kor-content-box">
    <a
      if={!opts.type}
      href="#/groups/admin/new"
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
            >group.name}</td>
          <td class="right nowrap" if={isAdmin()}>
            <a
              href="#/groups/admin/{group.id}/edit"
              title={t('verbs.edit')}
            ><i class="pen"></i></a>
            <a
              href="#/groups/admin/{category.id}/edit"
              title={t('verbs.edit')}
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
  </script>
  
</kor-admin-groups>