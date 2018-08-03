<kor-relationship>

  <div class="part">
    <virtual if={!editorActive}>
      <div class="kor-layout-commands">
        <virtual if={allowedToEdit()}>
          <kor-clipboard-control entity={to()} if={to().medium_id} />
          <a
            onclick={edit}
            title={t('objects.edit', {interpolations: {o: 'activerecord.models.relationship'}})}
          ><i class="pen"></i></a>
          <a
            onclick={delete}
            title={t('objects.delete', {interpolations: {o: 'activerecord.models.relationship'}})}
          ><i class="x"></i></a>
        </virtual>
      </div>

      <kor-entity
        no-clipboard={true}
        entity={relationship.to}
      />
      
      <a
        if={relationship.media_relations > 0}
        onclick={toggle}
        class="toggle"
      >
        <i show={!expanded} class="triangle_up"></i>
        <i show={expanded} class="triangle_down"></i>
      </a>

      <virtual if={relationship.properties.length > 0}>
        <hr />
        <div each={property in relationship.properties}>{property}</div>
      </virtual>

      <virtual if={relationship.datings.length > 0}>
        <hr />
        <div each={dating in relationship.datings}>
          {dating.label}: <strong>{dating.dating_string}</strong>
        </div>
      </virtual>

      <div class="clearfix"></div>

      <virtual if={expanded && data}>
        <kor-pagination
          page={opts.query.page}
          per-page={data.per_page}
          total={data.total}
          page-update-handler={pageUpdate}
        />
        <div class="clearfix"></div>
      </virtual>
    </virtual>
  </div>

  <table class="media-relations" if={expanded && data && !editorActive}>
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
      tag.relationship = tag.opts.relationship
      tag.opts.query ||= {}

    tag.to = -> tag.relationship.to

    tag.toggle = (event) ->
      event.preventDefault()
      tag.trigger 'toggle'

    tag.on 'toggle', (value) ->
      tag.expanded = (if value == undefined then !tag.expanded else value)
      fetchPage() if tag.expanded && !tag.data
      tag.update()

    tag.allowedToEdit = ->
      tag.allowedTo('edit', tag.opts.entity.collection_id) ||
      tag.allowedTo('edit', tag.to().collection_id)

    tag.edit = (event) ->
      event.preventDefault()
      wApp.bus.trigger 'modal', 'kor-relationship-editor', {
        directedRelationship: tag.relationship,
        onchange: reload
      }

    tag.delete = ->
      if confirm(tag.t('confirm.sure'))
        Zepto.ajax(
          type: 'DELETE'
          url: "/relationships/#{tag.relationship.relationship_id}"
          success: (data) ->
            h() if h = tag.opts.refreshHandler
      )

    tag.pageUpdate = (newPage) ->
      tag.opts.query.page = newPage
      fetchPage()

    reload = ->
      Zepto.ajax(
        url: '/relationships/' + tag.relationship.id,
        success: (data) ->
          tag.relationship = data
          tag.update()
      )

    fetchPage = ->
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