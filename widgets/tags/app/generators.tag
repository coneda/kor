<kor-generators>

  <div class="pull-right">
    <a href="#/kinds/{opts.kind.id}/generators/new" onclick={add}>
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    <kor-t
      key="activerecord.models.generator"
      with={ {count: 'other', capitalize: true} }>
    />
  </strong>
  <ul if={kind}>
    <li each={generator in kind.generators}>
      <div class="pull-right">
        <a href="#" onclick={edit(generator)}><i class="fa fa-edit"></i></a>
        <a href="#" onclick={remove(generator)}><i class="fa fa-remove"></i></a>
      </div>
      <a href="#" onclick={edit(generator)}>{generator.name}</a>
    </li>
  </ul>

  <virtual if={kind}>
    <div each={k in ancestry} show={k.generators.length > 0}>
      <strong>
        <kor-t key="inherited_from" />
        {k.name}
      </strong>
      <ul>
        <li each={generator in k.generators}>{generator.name}</li>
      </ul>
    </div>
  </virtual>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', -> refresh()
    tag.opts.notify.on 'refresh', -> refresh()

    tag.add = -> tag.opts.notify.trigger 'add-generator'

    tag.edit = (generator) ->
      (event) -> tag.opts.notify.trigger 'edit-generator', generator

    tag.remove = (generator) ->
      (event) ->
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/kinds/#{tag.opts.kind.id}/generators/#{generator.id}"
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
        data: {include: 'generators,ancestry'}
        success: (data) ->
          console.log data
          tag.kind = data
          tag.build_ancestry()
          tag.update()
      )


  </script>
</kor-generators>