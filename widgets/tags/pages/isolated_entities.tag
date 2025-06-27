<kor-isolated-entities>

  <div class="kor-content-box">
    <h1>{tcap('nouns.isolated_entity', {count: 'other'})}</h1>

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

    <kor-gallery-grid if={data} entities={data.records} />

    <div class="hr"></div>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />
  </div>

<script type="text/javascript">
  var tag = this
  tag.mixin(wApp.mixins.sessionAware)
  tag.mixin(wApp.mixins.i18n)
  tag.mixin(wApp.mixins.auth)
  tag.mixin(wApp.mixins.page)

  // On mount, check if user is allowed to edit, then fetch data and bind routing event
  tag.on('mount', function() {
    if (tag.allowedTo('edit')) {
      fetch()
      tag.on('routing:query', fetch)
      tag.title(tag.t('pages.isolated_entities'))
    } else {
      wApp.bus.trigger('access-denied')
    }
  })

  // Fetch isolated entities data from the server
  var fetch = function() {
    Zepto.ajax({
      url: '/entities',
      data: {
        include: 'kind',
        isolated: true,
        page: tag.opts.query.page,
        per_page: 16
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
</kor-isolated-entities>
