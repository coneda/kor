<kor-relationship>

  <div class="part">
    <div class="kor-layout-commands">
      <virtual if={allowedToEdit()}>
        <a onclick={activateEditor}><i class="pen"></i></a>
        <a onclick={delete}><i class="x"></i></a>
      </virtual>
    </div>

    <a
      class="name"
      href="#/entities/{opts.relationship.to.id}"
    >{to().display_name}</a>
    <span class="kind">{to().kind_name}</span>

    <a
      if={opts.relationship.media_relations > 0}
      onclick={toggle}
      class="toggle"
    >
      <i show={!expanded} class="triangle_up"></i>
      <i show={expanded} class="triangle_down"></i>
    </a>

    <virtual if={opts.relationship.properties.length > 0}>
      <div class="hr"></div>
      <div each={property in opts.relationship.properties}>{property}</div>
    </virtual>

    <div class="clearfix"></div>

    <kor-pagination
      if={expanded && data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />

    <div class="clearfix"></div>
  </div>

  <table class="media-relations" if={expanded && data}>
    <tbody>
      <tr each={row in wApp.utils.inGroupsOf(3, data.records)}>
        <td each={relationship in row}>
          <a href="#/entities/{relationship.to.id}">
            <img src={relationship.to.medium.url.thumbnail} />
          </a>
        </td>
      </tr>
    </tbody>      
  </table>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.info)

    tag.on 'mount', ->
      tag.opts.query ||= {}

    tag.to = -> tag.opts.relationship.to

    tag.toggle = (event) ->
      event.preventDefault()
      tag.expanded = !tag.expanded
      if tag.expanded && !tag.data
        fetch()
      tag.update()

    tag.allowedToEdit = ->
      tag.allowedTo('edit', tag.opts.entity.collection_id) ||
      tag.allowedTo('edit', tag.to().collection_id)

    tag.activateEditor = ->
    tag.delete = ->

    tag.pageUpdate = (newPage) ->
      tag.opts.query.page = newPage
      fetch()

    fetch = ->
      Zepto.ajax(
        url: "/entities/#{tag.to().id}/relationships"
        data: {
          page: tag.opts.query.page
          per_page: 9
          relation_name: tag.opts.name
          to_kind_id: tag.info().medium_kind_id
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

  </script>

</kor-relationship>