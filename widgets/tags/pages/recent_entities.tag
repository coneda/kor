<kor-recent-entities>

  <div class="kor-layout-left kor-layout-large" show={loaded}>
    <div class="kor-content-box">
      <h1>{tcap('nouns.new_entity', {count: 'other'})}</h1>

      <form>
        <kor-input
          if={collections}
          label={tcap('activerecord.attributes.entity.collection_id')}
          type="select"
          options={collections.records}
          placeholder={t('prompts.please_select')}
          onchange={collectionSelected}
          ref="collectionId"
          value={opts.query.collection_id}
        />
      </form>

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
            <th>{tcap('activerecord.attributes.entity.collection_id')}</th>
            <th>{tcap('activerecord.attributes.entity.updater')}</th>
          </tr>
        </thead>
        <tbody>
          <tr each={entity in data.records}>
            <td>
              <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a>
              <span class="kind">{entity.kind.name}</span>
            </td>
            <td>
              {entity.collection.name}
            </td>
            <td>
              {(entity.updater || entity.creator || {}).full_name}
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
      />
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', ->
      if tag.allowedTo('edit')
        Zepto.when(fetchCollections(), fetch()).then ->
          tag.loaded = true
          tag.update()
        tag.on 'routing:query', fetch
        h(tag.t('pages.recent_entities')) if h = tag.opts.handlers.pageTitleUpdate
      else
        h() if h = tag.opts.handlers.accessDenied

    fetch = ->
      Zepto.ajax(
        url: '/entities'
        data: {
          include: 'kind,users,collection'
          page: tag.opts.query.page
          collection_id: tag.opts.query.collection_id
          recent: true
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

    fetchCollections = ->
      Zepto.ajax(
        url: '/collections'
        success: (data) ->
          tag.collections = data
          tag.update()
      )

    tag.pageUpdate = (newPage) -> queryUpdate(page: newPage)
    tag.collectionSelected = (event) ->
      queryUpdate(page: 1, collection_id: tag.refs.collectionId.value())

    queryUpdate = (newQuery) -> h(newQuery) if h = tag.opts.handlers.queryUpdate

  </script>

</kor-recent-entities>