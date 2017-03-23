<kor-entity-selector>

  <a
    onclick={gotoTab('search')}
    class="{'selected': currentTab == 'search'}"
  >{t('nouns.search')}</a>
  |
  <a
    onclick={gotoTab('visited')}
    class="{'selected': currentTab == 'visited'}"
  >{t('recently_visited')}</a>
  |
  <a
    onclick={gotoTab('created')}
    class="{'selected': currentTab == 'created'}"
  >{t('recently_created')}</a>
  <virtual if={opts.riotValue}>
    |
    <a
      onclick={gotoTab('current')}
      class="{'selected': currentTab == 'current'}"
    >{t('currently_linked')}</a>
  </virtual>

  <!-- <div if={currentTab == 'search'}>
    <input name="terms" ng-model="terms" />
    <div
      kor-pagination="search_page"
      kor-total="results.total"
      kor-per-page="9"
    ></div>
  </div>

  <div if={currentTab == 'visited'}>
    <div
      kor-pagination="visited_page"
      kor-total="results.total"
      kor-per-page="9"
    ></div>
  </div>

  <div if={currentTab == 'created'}>
    <div
      kor-pagination="created_page"
      kor-total="results.total"
      kor-per-page="9"
    ></div>
  </div> -->

  <!-- <div if={currentTab == 'existing'}></div> -->

  <kor-pagination
    if={data}
    page={page}
    per-page={9}
    total={data.total}
    page-update-handler={pageUpdate}
  />

  <table if={!!groupedEntities}>
    <tbody>
      <tr each={row in groupedEntities}>
        <td
          each={record in row}
          onclick={select(record)}
          class="{selected: isSelected(record)}"
        >
          <kor-entity entity={record} />
        </td>
      </tr>
    </tbody>
  </table>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.currentTab = 'current'
    tag.page = 1

    tag.on 'criteria-changed', ->
      fetch()

    tag.gotoTab = (newTab) ->
      (event) ->
        event.preventDefault()
        if tag.currentTab != newTab
          tag.currentTab = newTab
          fetch()
          tag.update()

    tag.isSelected = (record) ->
      tag.opts.riotValue && (tag.opts.riotValue.id == record.id)

    tag.select = (record) -> tag.opts.entity = record

    tag.pageUpdate = (newPage) ->
      tag.page = newPage
      fetch()

    fetch = () ->
      switch tag.currentTab
        when 'current'
          tag.data = {records: [tag.opts.riotValue]}
          group()
        when 'visited'
          Zepto.ajax(
            url: '/entities/recently_visited'
            data: {
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
            url: '/entities/recently_created'
            data: {
              relation_name: tag.opts.relationName
              page: tag.page
              per_page: 9
            }
            success: (data) ->
              tag.data = data
              group()
          )

    group = ->
      tag.groupedEntities = wApp.utils.inGroupsOf(3, tag.data.records)
      tag.update()

  </script>

</kor-entity-selector>