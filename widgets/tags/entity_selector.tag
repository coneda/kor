<kor-entity-selector>
  <div class="pull-right">
    <a
      href="#"
      onclick={gotoTab('search')}
      class="{'selected': currentTab == 'search'}"
    >{t('nouns.search')}</a>
    |
    <a
      href="#"
      onclick={gotoTab('visited')}
      class="{'selected': currentTab == 'visited'}"
    >{t('recently_visited')}</a>
    |
    <a
      href="#"
      onclick={gotoTab('created')}
      class="{'selected': currentTab == 'created'}"
    >{t('recently_created')}</a>
    <virtual if={existing}>
      |
      <a
        href="#"
        onclick={gotoTab('current')}
        class="{'selected': currentTab == 'current'}"
      >{t('currently_linked')}</a>
    </virtual>
  </div>

  <div class="header">
    <label>{opts.label || tcap('activerecord.models.entity')}</label>
  </div>

  <kor-input
    if={currentTab == 'search'}
    name="terms"
    placeholder={tcap('nouns.term')}
    ref="terms"
    onkeyup={search}
  />

  <kor-pagination
    if={data}
    page={page}
    per-page={9}
    total={data.total}
    on-paginate={paginate}
  />

  <table if={!!groupedEntities}>
    <tbody>
      <tr each={row in groupedEntities}>
        <td
          each={record in row}
          onclick={select}
          class="{selected: isSelected(record)}"
        >
          <kor-entity
            if={record}
            entity={record}
          />
        </td>
      </tr>
    </tbody>
  </table>

  <div class="errors" if={opts.errors}>
    <div each={e in opts.errors}>{e}</div>
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.page = 1

    tag.on 'before-mount', ->
      tag.id = tag.opts.riotValue
      if tag.id
        tag.existing = true

      tag.currentTab = if tag.id then 'current' else 'search'
      tag.trigger 'reload'
      tag.update()
      
    tag.on 'reload', ->
      fetch()

    tag.gotoTab = (newTab) ->
      (event) ->
        event.preventDefault()
        if tag.currentTab != newTab
          tag.currentTab = newTab
          tag.data = {}
          tag.groupedEntities = []
          fetch()
          tag.update()

    tag.isSelected = (record) -> 
      record && tag.id == record.id

    tag.select = (event) ->
      event.preventDefault()
      record = event.item.record
      if tag.isSelected(record)
        tag.id = undefined
      else
        tag.id = record.id
      h() if h = tag.opts.onchange

    tag.search = ->
      if tag.to
        window.clearTimeout(tag.to)
      tag.to = window.setTimeout(fetch, 300)

    tag.paginate = (newPage) ->
      tag.page = newPage
      fetch()

    tag.value = -> tag.id

    fetch = () ->
      switch tag.currentTab
        when 'current'
          if tag.opts.riotValue
            Zepto.ajax(
              url: '/entities/' + tag.opts.riotValue
              success: (data) ->
                tag.data = {records: [data]}
                group()
            )
        when 'visited'
          Zepto.ajax(
            url: '/entities'
            data: {
              id: wApp.entityHistory.ids()
              relation_name: tag.opts.relationName
              page: tag.page
              per_page: 9
            }
            success: (data) ->
              tag.data = data
              group()
          )
        when 'created'
          Zepto.ajax(
            url: '/entities'
            data: {
              relation_name: tag.opts.relationName
              page: tag.page
              per_page: 9,
              sort: 'created_at',
              direction: 'desc'
            }
            success: (data) ->
              tag.data = data
              group()
          )
        when 'search'
          if tag.refs.terms
            Zepto.ajax(
              url: '/entities'
              data: {
                terms: tag.refs.terms.value(),
                relation_name: tag.opts.relationName,
                per_page: 9,
                page: tag.page
              }
              success: (data) ->
                tag.data = data
                group()
            )

    group = ->
      tag.groupedEntities = wApp.utils.inGroupsOf(3, tag.data.records, null)
      tag.update()

  </script>

</kor-entity-selector>