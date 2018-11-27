<kor-new-media>
  <kor-help-button key="new_entries" />

  <div class="kor-content-box">
    <h1>{tcap('pages.new_media')}</h1>

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

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'mount', ->
      fetch()
      tag.on 'routing:query', fetch
      h(tag.t('pages.new_media')) if h = tag.opts.handlers.pageTitleUpdate

    tag.on 'unmount', ->
      tag.off 'routing:query', fetch

    fetch = ->
      Zepto.ajax(
        url: '/entities'
        data: {
          include: 'kind,gallery_data',
          page: tag.opts.query.page,
          sort: 'created_at',
          direction: 'desc',
          kind_id: wApp.info.data.medium_kind_id
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

    tag.pageUpdate = (newPage) -> queryUpdate(page: newPage)

    queryUpdate = (newQuery) -> h(newQuery) if h = tag.opts.handlers.queryUpdate

  </script>

</kor-new-media>