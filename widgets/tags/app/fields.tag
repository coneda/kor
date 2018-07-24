<kor-fields>

  <div class="pull-right kor-text-right">
    <a href="#/kinds/{opts.kind.id}/edit/fields/new">
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    {tcap('activerecord.models.field', {count: 'other'})}
  </strong>

  <div class="clearfix"></div>

  <ul if={opts.kind}>
    <li each={field in opts.kind.fields}>
      <div class="pull-right kor-text-right">
        <a href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit"><i class="fa fa-edit"></i></a>
        <a href="#" onclick={remove(field)}><i class="fa fa-remove"></i></a>
      </div>
      <a href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit">{field.name}</a>
    </li>
  </ul>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

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

  </script>
</kor-fields>