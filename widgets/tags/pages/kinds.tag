<kor-kinds>

  <div class="kor-content-box">
    <a
      if={isKindAdmin()}
      href="#/kinds/new"
      class="pull-right"
      title={t('verbs.add')}
    ><i class="fa fa-plus-square"></i></a>
    <h1>{tcap('activerecord.models.kind', {count: 'other'})}</h1>

    <form class="inline">
      <kor-input
        label={tcap('search_term')}
        name="terms"
        onkeyup={delayedSubmit}
        ref="terms"
      />

      <kor-input
        label={tcap('hide_abstract')}
        type="checkbox"
        name="hideAbstract"
        onchange={submit}
        ref="hideAbstract"
      />
    </form>

    <div class="hr"></div>

  <virtual if={filteredRecords && filteredRecords.length}>
    <table each={records, schema in groupedResults} class="kor_table text-left">
      <thead>
        <tr>
          <th>{schema == 'null' ? tcap('no_schema') : schema}</th>
          <th if={isKindAdmin()}></th>
        </tr>
      </thead>
      <tbody>
        <tr each={kind in records}>
          <td class={active: !kind.abstract}>
            <div class="name">
              <a href="#/kinds/{kind.id}/edit">{kind.name}</a>
            </div>
            <div show={kind.fields.length}>
              <span class="label">
                {t('activerecord.models.field', {count: 'other'})}:
              </span>
              {fieldNamesFor(kind)}
            </div>
            <div show={kind.generators.length}>
              <span class="label">
                {t('activerecord.models.generator', {count: 'other'})}:
              </span>
              {generatorNamesFor(kind)}
            </div>
          </td>
          <td class="buttons" if={isKindAdmin()}>
            <a href="#/kinds/{kind.id}/edit" title={t('verbs.edit')}><i class="fa fa-edit"></i></a>
            <a
              if={kind.removable}
              href="#/kinds/{kind.id}"
              onclick={delete(kind)}
              title={t('verbs.delete')}
            ><i class="fa fa-remove"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </virtual>

  <script type="text/coffee">
    tag = this
    tag.requireRoles = ['kind_admin']
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.page)

    tag.on 'mount', ->
      tag.title(tag.t('activerecord.models.kind', {count: 'other'}))
      fetch()

    tag.filters = {}

    tag.delete = (kind) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm tag.t('confirm.general')
          Zepto.ajax(
            type: 'DELETE'
            url: "/kinds/#{kind.id}"
            success: -> fetch()
          )

    tag.isMedia = (kind) -> kind.uuid == wApp.data.medium_kind_uuid

    tag.fieldNamesFor = (kind) -> (k.show_label for k in kind.fields).join(', ')
    tag.generatorNamesFor = (kind) ->
      (g.name for g in kind.generators).join(', ')

    tag.submit = ->
      tag.filters.terms = tag.refs['terms'].value()
      tag.filters.hideAbstract = tag.refs['hideAbstract'].value()
      filter_records()
      groupAndSortRecords()
      tag.update()

    tag.delayedSubmit = (event) ->
      if tag.delayedTimeout
        tag.delayedTimeout.clearTimeout 
        tag.delayedTimeout = undefined

      tag.delayedTimeout = window.setTimeout(tag.submit, 300)
      true

    filter_records = ->
      tag.filteredRecords = if tag.filters.terms
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
        tag.filteredRecords = tag.filteredRecords.filter (kind) -> !kind.abstract

    typeCompare = (x, y) ->
      if x.match(/^E\d+/) && y.match(/^E\d+/)
        x = parseInt(x.replace(/^E/, '').split(' ')[0])
        y = parseInt(y.replace(/^E/, '').split(' ')[0])
      if x > y
        1
      else
        if x == y
          0
        else
          -1

    groupAndSortRecords = ->
      results = {}
      for r in tag.filteredRecords
        results[r['schema']] ||= []
        results[r['schema']].push r
      for k, v of results
        results[k] = v.sort((x, y) -> typeCompare(x.name, y.name))
      tag.groupedResults = results

    fetch = ->
      Zepto.ajax(
        url: '/kinds'
        data: {include: 'generators,fields,inheritance'}
        success: (data) ->
          tag.data = data
          filter_records()
          groupAndSortRecords()
          tag.update()
      )

  </script>

</kor-kinds>