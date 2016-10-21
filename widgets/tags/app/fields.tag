<kor-fields>

  <div class="pull-right">
    <a href="#/kinds/{opts.kind.id}/fields/new" onclick={add}>
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    <kor-t
      key="activerecord.models.field"
      with={ {count: 'other', capitalize: true} }>
    />
  </strong>
  <ul>
    <li each={field in kind.fields}>
      <div class="pull-right">
        <a href="#" onclick={edit(field)}><i class="fa fa-edit"></i></a>
        <a href="#" onclick={remove(field)}><i class="fa fa-remove"></i></a>
      </div>
      <a href="#" onclick={edit(field)}>{field.name}</a>
    </li>
  </ul>

  <div each={k in ancestry} show={k.fields.length > 0}>
    <strong>
      <kor-t key="inherited_from" />
      {k.name}
    </strong>
    <ul>
      <li each={field in k.fields}>{field.name}</li>
    </ul>
  </div>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', -> refresh()
    tag.opts.notify.on 'refresh', -> refresh()

    tag.add = -> tag.opts.notify.trigger 'add'

    tag.edit = (field) ->
      (event) -> tag.opts.notify.trigger 'edit', field

    tag.remove = (field) ->
      (event) ->
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          $.ajax(
            type: 'delete'
            url: "/kinds/#{tag.opts.kind.id}/fields/#{field.id}"
            success: -> refresh()
          )

    tag.build_ancestry = ->
      results = []
      todo = tag.kind.parents
      while todo.length > 0
        new_todo = []
        for k in todo
          results.push(k)
          new_todo = new_todo.concat(k.parents)
        todo = new_todo
      tag.ancestry = results

    refresh = ->
      $.ajax(
        url: "/kinds/#{tag.opts.kind.id}"
        data: {include: 'fields,ancestry'}
        success: (data) ->
          tag.kind = data
          tag.build_ancestry()
          tag.update()
      )


  </script>
</kor-fields>