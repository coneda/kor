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

  <script type="text/coffee">
    tag = this

    tag.on 'mount', -> refresh()
    tag.opts.notify.on 'refresh', -> refresh()

    tag.add = (event) ->
      event.preventDefault()
      tag.opts.notify.trigger 'add-generator'

    tag.edit = (generator) ->
      (event) ->
        event.preventDefault()
        tag.opts.notify.trigger 'edit-generator', generator

    tag.remove = (generator) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/kinds/#{tag.opts.kind.id}/generators/#{generator.id}"
            success: -> refresh()
          )

    refresh = ->
      Zepto.ajax(
        url: "/kinds/#{tag.opts.kind.id}"
        data: {include: 'generators,inheritance'}
        success: (data) ->
          # console.log data
          tag.kind = data
          tag.update()
      )


  </script>
</kor-generators>