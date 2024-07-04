<kor-relation>

  <div class="name">
    <a
      title={t('order_actions.drop_custom')}
      class="unorder"
      href="#"
      onclick={unorder}
    >
      <i class="fa fa-sort"></i>
    </a>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      on-paginate={pageUpdate}
    />

    {opts.name}

    <a
      if={expandable()}
      title={expanded ? t('verbs.collapse') : t('verbs.expand')}
      onclick={toggle}
      class="toggle"
      href="#"
    >
      <i show={!expanded} class="fa fa-chevron-up"></i>
      <i show={expanded} class="fa fa-chevron-down"></i>
    </a>

    <div class="clearfix"></div>
  </div>

  <virtual if={data}>
    <kor-relationship
      each={relationship, i in data.records}
      entity={parent.opts.entity}
      relationship={relationship}
      position={data.per_page * (data.page - 1) + i + 1}
    />
  </virtual>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.info)

    tag.on 'mount', ->
      tag.opts.query ||= {}
      wApp.bus.on 'relationship-reorder', fetch
      fetch()

    tag.on 'unmount', ->
      wApp.bus.off 'relationship-reorder', fetch

    tag.reFetch = fetch

    tag.expandable = ->
      return false unless tag.data
      for r in tag.data.records
        return true if r.media_relations > 0
      false

    tag.toggle = (event) ->
      event.preventDefault()
      tag.expanded = !tag.expanded
      updateExpansion()

    tag.pageUpdate = (newPage) ->
      opts.query.page = newPage
      fetch()

    tag.unorder = (event) ->
      event.preventDefault()

      Zepto.ajax(
        type: "DELETE"
        url: "/relationships/unorder"
        data: JSON.stringify({
          from_id: tag.opts.entity.id
          relation_name: tag.opts.name
        })
        success: (data) ->
          tag.refresh()
      )

    tag.refresh = -> fetch()

    fetch = ->
      Zepto.ajax(
        url: "/relationships"
        data: {
          from_entity_id: tag.opts.entity.id
          page: tag.opts.query.page
          relation_name: tag.opts.name
          except_to_kind_id: tag.info().medium_kind_id,
          include: 'all'
        }
        success: (data) ->
          tag.data = data
          tag.update()
          updateExpansion()
      )

    updateExpansion = ->
      unless tag.expanded == undefined
        for r in tag.tags['kor-relationship']
          r.trigger 'toggle', tag.expanded

  </script>

</kor-relation>