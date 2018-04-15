<kor-generators>

  <div class="pull-right kor-text-right">
    <a href="#/kinds/{opts.kind.id}/edit/generators/new">
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    {tcap('activerecord.models.generator', {count: 'other'})}
  </strong>

  <div class="clearfix"></div>

  <ul if={opts.kind}>
    <li each={generator in opts.kind.generators}>
      <div class="pull-right kor-text-right">
        <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}/edit"><i class="fa fa-edit"></i></a>
        <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}" onclick={remove(generator)}><i class="fa fa-remove"></i></a>
      </div>
      <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}/edit">{generator.name}</a>
      <div class="clearfix"></div>
    </li>
  </ul>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'mount', ->
      console.log(tag.opts.kind)

    tag.remove = (generator) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/kinds/#{tag.opts.kind.id}/generators/#{generator.id}"
            success: ->
              route("/kinds/#{tag.opts.kind.id}/edit")
              tag.opts.notify.trigger 'refresh'
          )

  </script>
</kor-generators>