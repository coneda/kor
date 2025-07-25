<kor-invalid-entities>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1>{tcap('nouns.invalid_entity', {count: 'other'})}</h1>

      <kor-pagination
        if={data}
        page={opts.query.page}
        per-page={data.per_page}
        total={data.total}
        page-update-handler={pageUpdate}
      />

      <div class="hr"></div>

      <span show={data && data.total == 0}>
        {tcap('objects.none_found', {interpolations: {o: 'activerecord.models.entity.other'}})}
      </span>

      <table if={data && data.total > 0}>
        <thead>
          <tr>
            <th>{tcap('activerecord.attributes.entity.name')}</th>
          </tr>
        </thead>
        <tbody>
          <tr each={entity in data.records}>
            <td>
              <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a>
              <span class="kind">{entity.kind.name}</span>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="hr"></div>

      <kor-pagination
        if={data}
        page={opts.query.page}
        per-page={data.per_page}
        total={data.total}
        page-update-handler={pageUpdate}
        class="top"
      />
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this
  tag.mixin(wApp.mixins.sessionAware)
  tag.mixin(wApp.mixins.i18n)
  tag.mixin(wApp.mixins.auth)
  tag.mixin(wApp.mixins.page)

  // On mount, check permission and fetch invalid entities
  tag.on('mount', function() {
    if (tag.allowedTo('delete')) {
      fetch()
      tag.on('routing:query', fetch)
      wApp.bus.trigger('page-title', tag.t('pages.invalid_entities'))
    } else {
      wApp.bus.trigger('access-denied')
    }
  })

  // Fetch invalid entities from the server
  var fetch = function() {
    Zepto.ajax({
      url: '/entities',
      data: {
        invalid: true,
        include: 'kind',
        page: tag.opts.query.page,
        per_page: 20,
        sort: 'id'
      },
      success: function(data) {
        tag.data = data
        tag.update()
      }
    })
  }

  // Handle page change (pagination)
  tag.pageUpdate = function(newPage) {
    queryUpdate({ page: newPage })
  }

  // Trigger query update event
  var queryUpdate = function(newQuery) {
    wApp.bus.trigger('query-update', newQuery)
  }
</script>

</kor-invalid-entities>
