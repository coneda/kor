<kor-relation>

  <div class="name">
    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      on-paginate={pageUpdate}
    />

    {opts.name}

    <a onclick={toggle} class="toggle">
      <i show={!expanded} class="triangle_up"></i>
      <i show={expanded} class="triangle_down"></i>
    </a>

    <div class="clearfix"></div>
  </div>

  <virtual if={data}>
    <kor-relationship
      each={relationship in data.records}
      entity={parent.opts.entity}
      relationship={relationship}
      refresh-handler={parent.refresh}
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
      fetch()

    tag.toggle = (event) ->
      event.preventDefault()
      tag.expanded = !tag.expanded
      updateExpansion()

    tag.pageUpdate = (newPage) ->
      opts.query.page = newPage
      fetch()

    tag.refresh = -> fetch()

    fetch = ->
      Zepto.ajax(
        url: "/entities/#{tag.opts.entity.id}/relationships"
        data: {
          page: tag.opts.query.page
          relation_name: tag.opts.name
          except_to_kind_id: tag.info().medium_kind_id
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