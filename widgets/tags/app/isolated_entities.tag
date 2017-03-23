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
      {tcap('objects.none_found', {interpolations: {o: 'nouns.entity.one'}})}
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

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', ->
      if tag.allowedTo('edit')
        fetch()
        tag.on 'routing:query', fetch
        h(tag.t('pages.isolated_entities')) if h = tag.opts.handlers.pageTitleUpdate
      else
        h() if h = tag.opts.handlers.accessDenied

    fetch = ->
      Zepto.ajax(
        url: '/entities/isolated'
        data: {
          include: 'kind',
          page: tag.opts.query.page
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

    tag.pageUpdate = (newPage) -> queryUpdate(page: newPage)

    queryUpdate = (newQuery) -> h(newQuery) if h = tag.opts.handlers.queryUpdate

  </script>

</kor-isolated-entities>