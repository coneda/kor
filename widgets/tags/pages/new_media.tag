<kor-new-media>
  <kor-help-button key="new_entries" />

  <div class="kor-content-box">
    <h1>{tcap(config().new_media_label)}</h1>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
      class="top"
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
    tag.mixin(wApp.mixins.page)
    tag.mixin(wApp.mixins.config)

    tag.on 'mount', ->
      tag.title(tag.t('pages.new_media'))
      fetch()
      tag.on 'routing:query', fetch
      tag.title(tag.t('pages.new_media'))

    tag.on 'unmount', ->
      tag.off 'routing:query', fetch

    fetch = ->
      Zepto.ajax(
        url: '/entities'
        data: {
          engine: 'active_record',
          include: 'kind,gallery_data',
          page: tag.opts.query.page,
          per_page: 16,
          sort: 'created_at',
          direction: 'desc',
          kind_id: wApp.info.data.medium_kind_id
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

    tag.pageUpdate = (newPage) -> queryUpdate(page: newPage)
    queryUpdate = (newQuery) -> wApp.bus.trigger('query-update', newQuery)

  </script>

</kor-new-media>