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
  <ul if={kind}>
    <li each={field in kind.fields}>
      <div class="pull-right">
        <a href="#" onclick={edit(field)}><i class="fa fa-edit"></i></a>
        <a href="#" onclick={remove(field)}><i class="fa fa-remove"></i></a>
      </div>
      <a href="#" onclick={edit(field)}>{field.name}</a>
    </li>
  </ul>

  <div if={ancestry} each={k in ancestry} show={k.fields.length} >
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

    tag.add = (event) ->
      event.preventDefault()
      tag.opts.notify.trigger 'add-field'

    tag.edit = (field) ->
      (event) ->
        event.preventDefault()
        tag.opts.notify.trigger 'edit-field', field

    tag.remove = (field) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/kinds/#{tag.opts.kind.id}/fields/#{field.id}"
            success: -> refresh()
          )

    tag.build_ancestry = ->
      results = []
      result_ids = []
      todo = tag.kind.parents
      while todo.length > 0
        new_todo = []
        for k in todo
          if result_ids.indexOf(k.id) == -1
            results.push(k)
            result_ids.push(k.id)
            new_todo = new_todo.concat(k.parents)
        todo = new_todo
      tag.ancestry = results

    refresh = ->
      Zepto.ajax(
        url: "/kinds/#{tag.opts.kind.id}"
        data: {include: 'fields,ancestry'}
        success: (data) ->
          # console.log data
          tag.kind = data
          tag.build_ancestry()
          tag.update()
      )


  </script>
</kor-fields>