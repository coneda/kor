<kor-fields>

  <div class="pull-right kor-text-right">
    <a
      href="#/kinds/{opts.kind.id}/edit/fields/new"
      title={t('verbs.add')}
    >
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    {tcap('activerecord.models.field', {count: 'other'})}
  </strong>

  <div class="clearfix"></div>

  <ul if={opts.kind}>
    <li each={field in opts.kind.fields} key={field.id} data-id={field.id}>
      <div class="pull-right kor-text-right">
        <a
          href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit"
          title={t('verbs.edit')}
        ><i class="fa fa-edit"></i></a>
        <a
          href="#"
          onclick={remove(field)}
          title={t('verbs.delete')}
        ><i class="fa fa-remove"></i></a>
        <a
          class="handle"
          href="#"
          onclick={preventDefault}
          title={t('change_order')}
        ><i class="fa fa-bars"></i></a>
      </div>
      <a
        href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit"
        title={field.show_label}
      >
        {wApp.utils.shorten(field.name, 20)}
      </a>
      <div class="clearfix"></div>
    </li>
  </ul>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'mount', () ->
      ul = tag.root.querySelector('ul')
      new Sortable(ul, {
        draggable: 'li'
        handle: '.handle'
        forceFallback: true
        onEnd: (event) -> 
          if (event.newIndex != event.oldIndex)
            id = event.item.getAttribute('data-id')
            params = JSON.stringify({field: {position: event.newIndex}})
            Zepto.ajax(
              type: 'PATCH'
              url: "/kinds/#{tag.opts.kind.id}/fields/#{id}"
              data: params
              success: -> tag.opts.notify.trigger 'refresh'
            )
      })

    tag.remove = (field) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'DELETE'
            url: "/kinds/#{tag.opts.kind.id}/fields/#{field.id}"
            success: ->
              route("/kinds/#{tag.opts.kind.id}/edit")
              tag.opts.notify.trigger 'refresh'
          )

    tag.preventDefault = (event) -> event.preventDefault()

  </script>
</kor-fields>