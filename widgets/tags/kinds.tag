<kor-kinds>
  <h1>
    {wApp.i18n.t('activerecord.models.kind', {capitalize: true, count: 'other'})}
  </h1>

  <form class="kor-horizontal" >

    <kor-field
      label-key="search_term"
      field-id="terms"
      onkeyup={delayedSubmit}
    />

    <kor-field
      label-key="hide_abstract"
      type="checkbox"
      field-id="hideAbstract"
      onchange={submit}
    />

    <div class="hr"></div>
  </form>

  <div class="text-right">
    <a href="#/kinds/new">
      <i class="fa fa-plus-square"></i>
    </a>
  </div>

  <table class="kor_table text-left" if={filtered_records}>
    <thead>
      <tr>
        <th>{wApp.i18n.t('activerecord.attributes.kind.name')}</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr each={kind in filtered_records}>
        <td class={active: !kind.abstract}>
          <div class="name">
            <a href="#/kinds/{kind.id}">{kind.name}</a>
          </div>
          <div show={kind.fields.length}>
            <span class="label">
              {wApp.i18n.t('activerecord.models.field', {count: 'other'})}:
            </span>
            {fieldNamesFor(kind)}
          </div>
          <div show={kind.generators.length}>
            <span class="label">
              {wApp.i18n.t('activerecord.models.generator', {count: 'other'})}:
            </span>
            {generatorNamesFor(kind)}
          </div>
        </td>
        <td class="text-right buttons">
          <a href="#/kinds/{kind.id}"><i class="fa fa-edit"></i></a>
          <a
            if={kind.removable}
            href="#/kinds/{kind.id}"
            onclick={delete(kind)}
          ><i class="fa fa-remove"></i></a>
        </td>
      </tr>
    </tbody>
  </table>

  <script type="text/coffee">
    tag = this
    tag.requireRoles = ['kind_admin']
    tag.mixin(wApp.mixins.session)

    tag.on 'mount', -> fetch()

    tag.filters = {}

    tag.delete = (kind) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/kinds/#{kind.id}"
            success: -> fetch()
          )

    tag.isMedia = (kind) -> kind.uuid == wApp.data.medium_kind_uuid

    tag.fieldNamesFor = (kind) -> (k.show_label for k in kind.fields).join(', ')
    tag.generatorNamesFor = (kind) ->
      (g.name for g in kind.generators).join(', ')

    tag.submit = ->
      tag.filters.terms = tag.formFields['terms'].val()
      tag.filters.hideAbstract = tag.formFields['hideAbstract'].val()
      filter_records()
      tag.update()

    tag.delayedSubmit = (event) ->
      if tag.delayedTimeout
        tag.delayedTimeout.clearTimeout 
        tag.delayedTimeout = undefined

      tag.delayedTimeout = window.setTimeout(tag.submit, 300)
      true

    filter_records = ->
      tag.filtered_records = if tag.filters.terms
        re = new RegExp("#{tag.filters.terms}", 'i')
        results = []
        for kind in tag.data.records
          if kind.name.match(re)
            if results.indexOf(kind) == -1
              results.push(kind)
        results
      else
        tag.data.records

      if tag.filters.hideAbstract
        tag.filtered_records = tag.filtered_records.filter (kind) -> !kind.abstract

    fetch = ->
      Zepto.ajax(
        type: 'get'
        url: '/kinds'
        data: {include: 'generators,fields,inheritance'}
        success: (data) ->
          tag.data = data
          filter_records()
          tag.update()
      )

  </script>

</kor-kinds>