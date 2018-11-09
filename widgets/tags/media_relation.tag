<kor-media-relation>

  <div class="name">
    {opts.name}

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      on-paginate={pageUpdate}
    />

    <div class="clearfix"></div>
  </div>

  <virtual if={data}>
    <kor-relationship
      each={relationship in data.records}
      entity={parent.opts.entity}
      relationship={relationship}
    />
  </virtual>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.info)

    tag.on 'mount', ->
      wApp.bus.on 'relationship-created', fetch
      wApp.bus.on 'relationship-updated', fetch
      wApp.bus.on 'relationship-deleted', fetch
      tag.opts.query ||= {}
      fetch()

    tag.on 'unmount', ->
      wApp.bus.off 'relationship-deleted', fetch
      wApp.bus.off 'relationship-updated', fetch
      wApp.bus.off 'relationship-created', fetch

    tag.pageUpdate = (newPage) ->
      opts.query.page = newPage
      fetch()

    tag.refresh = -> fetch()

    fetch = ->
      Zepto.ajax(
        url: "relationships"
        data: {
          from_entity_id: tag.opts.entity.id
          page: tag.opts.query.page
          relation_name: tag.opts.name
          to_kind_id: tag.info().medium_kind_id
          include: 'all'
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

  </script>

</kor-media-relation>