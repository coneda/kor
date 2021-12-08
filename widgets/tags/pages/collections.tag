<kor-collections>

  <div class="kor-content-box">
    <a
      href="#/collections/new"
      class="pull-right"
      title={t('objects.new', {interpolations: {o: t('activerecord.models.collection')}})}
    ><i class="fa fa-plus-square"></i></a>
    <h1>{tcap('activerecord.models.collection', {count: 'other'})}</h1>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />

    <table>
      <thead>
        <th>{tcap('activerecord.attributes.collection.name')}</th>
        <th class="right"># {tcap('activerecord.models.entity.other')}</th>
        <th class="right"></th>
      </thead>
      <tbody if={data}>
        <tr each={collection in data.records}>
          <td>
            {collection.name}
            <span if={collection.owner}>
              ({t('activerecord.models.user')}:
              <a href="#/users/{collection.owner.id}/edit">{collection.owner.full_name}</a>)
            </span>
          </td>
          <td class="right">{collection.entity_count}</td>
          <td class="right">
            <a
              href="#/collections/{collection.id}/edit"
              title={t('verbs.edit')}
            ><i class="fa fa-pencil"></i></a>
            <a
              href="#/collections/{collection.id}/destroy"
              onclick={onDeleteClicked}
              title={t('verbs.delete')}
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
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      tag.title(tag.t('activerecord.models.collection', {count: 'other'}))
      fetch()
      tag.on('routing:query', fetch)
    })

    tag.on('unmount', function() {
      tag.off('routing:query', fetch)
    })

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      if (wApp.utils.confirm())
        destroy(event.item.collection.id);
    }

    tag.pageUpdate = function(newPage) {
      wApp.bus.trigger('query-update', {page: newPage})
    }

    var destroy = function(id) {
      Zepto.ajax({
        type: 'DELETE',
        url: '/collections/' + id,
        success: fetch,
        error: function(xhr) {
          tag.errors = JSON.parse(xhr.responseText).errors
          wApp.utils.scrollToTop()
        }
      })
    }

    fetch = function() {
      var page = wApp.routing.query()['page'] || 1
      Zepto.ajax({
        url: '/collections',
        data: {include: 'counts,owner', page: page},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

    tag.fetch = fetch
  </script>
</kor-collections>