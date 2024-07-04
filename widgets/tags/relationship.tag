<kor-relationship>

  <div class="part">
    <virtual if={!editorActive}>
      <div class="kor-layout-commands">
        <virtual if={allowedToEdit()}>
          <kor-clipboard-control entity={to()} if={to().medium_id} />
          <a
            href="#"
            onclick={edit}
            title={t('objects.edit', {interpolations: {o: 'activerecord.models.relationship'}})}
          ><i class="fa fa-pencil"></i></a>
          <a
            href="#"
            onclick={toTop}
            title={t('order_actions.to_top')}
            class="to_top"
          ><i class="fa fa-angle-double-up"></i></a>
          <a
            href="#"
            onclick={up}
            title={t('order_actions.up')}
            class="up"
          ><i class="fa fa-angle-up"></i></a>
          <a
            href="#"
            onclick={down}
            title={t('order_actions.down')}
            class="down"
          ><i class="fa fa-angle-down"></i></a>
          <a
            href="#"
            onclick={toBottom}
            title={t('order_actions.to_bottom')}
            class="to_bottom"
          ><i class="fa fa-angle-double-down"></i></a>
          <a
            href="#"
            onclick={delete}
            title={t('objects.delete', {interpolations: {o: 'activerecord.models.relationship'}})}
          ><i class="fa fa-trash"></i></a>
        </virtual>
      </div>

      <kor-entity
        no-clipboard={true}
        entity={relationship.to}
      />
      
      <a
        if="{relationship.media_relations > 0}"
        title={expanded ? t('verbs.collapse') : t('verbs.expand')}
        onclick={toggle}
        class="toggle"
        href="#"
      >
        <i show={!expanded} class="fa fa-chevron-up"></i>
        <i show={expanded} class="fa fa-chevron-down"></i>
      </a>

      <virtual if={relationship.properties.length > 0}>
        <div class="hr"></div>
        <div each={property in relationship.properties}>{property}</div>
      </virtual>

      <virtual if={relationship.datings.length > 0}>
        <div class="hr"></div>
        <div each={dating in relationship.datings}>
          {dating.label}: <strong>{dating.dating_string}</strong>
        </div>
      </virtual>

      <div class="clearfix"></div>

      <virtual if={expanded && data}>
        <kor-pagination
          page={query.page}
          per-page={data.per_page}
          total={data.total}
          on-paginate={pageUpdate}
        />
        <div class="clearfix"></div>
      </virtual>
    </virtual>
  </div>

  <table class="media-relations" if={expanded && data && !editorActive}>
    <tbody>
      <tr each={row in wApp.utils.inGroupsOf(3, data.records, null)}>
        <td each={relationship in row}>
          <virtual if={relationship}>
            <div class="kor-text-right">
              <kor-clipboard-control entity={relationship.to} />
            </div>
            <a href="#/entities/{relationship.to.id}">
              <img class="medium" src={relationship.to.medium.url.thumbnail} />
            </a>
          </virtual>
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
      tag.position = tag.opts.position
      tag.query ||= {}

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
      }

    tag.delete = (event) ->
      event.preventDefault()
      if confirm(tag.t('confirm.sure'))
        Zepto.ajax(
          type: 'DELETE'
          url: "/relationships/#{tag.relationship.relationship_id}"
          success: (data) ->
            wApp.bus.trigger('relationship-deleted')
      )

    tag.toTop = (event) ->
      event.preventDefault()
      tag.toPosition('top')

    tag.up = (event) ->
      event.preventDefault()
      tag.toPosition(tag.opts.position - 1)

    tag.down = (event) ->
      event.preventDefault()
      tag.toPosition(tag.opts.position + 1)

    tag.toBottom = (event) ->
      event.preventDefault()
      tag.toPosition('bottom')

    tag.toPosition = (position) ->
      event.preventDefault()
      Zepto.ajax(
        type: 'PATCH'
        url: "/relationships/#{tag.relationship.id}/reorder"
        data: JSON.stringify({position: position})
        success: (data) ->
          wApp.bus.trigger('relationship-reorder')
      )

    tag.pageUpdate = (newPage) ->
      tag.query.page = newPage
      fetchPage()

    fetchPage = ->
      Zepto.ajax(
        url: "/relationships"
        data: {
          page: tag.query.page
          per_page: 9
          relation_name: tag.opts.name
          to_kind_id: tag.info().medium_kind_id
          from_entity_id: tag.to().id,
          include: 'to,properties,datings'
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

  </script>

</kor-relationship>