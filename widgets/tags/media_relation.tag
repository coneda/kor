<kor-media-relation>

  <div class="name">
    {opts.name}

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />

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
          to_kind_id: tag.info().medium_kind_id
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

  </script>

</kor-media-relation>