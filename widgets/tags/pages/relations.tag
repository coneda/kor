<kor-relations>

  <div class="kor-content-box">
    <div class="pull-right" if={isRelationAdmin()}>
      <a
        href="#"
        title={t('verbs.merge')}
        onclick={toggleMerge}
      ><i class="fa fa-compress" aria-hidden="true"></i></a>
      <a
        href="#/relations/new"
        title={t('verbs.add')}
      ><i class="fa fa-plus-square"></i></a>
    </div>

    <h1>
      {tcap('activerecord.models.relation', {count: 'other'})}
    </h1>

    <form class="kor-horizontal">
      <kor-input
        name="terms"
        label={tcap('search_term')}
        onkeyup={delayedSubmit}
      />

      <div class="hr"></div>
    </form>

    <div show={merge}>
      <div class="hr"></div>
      <kor-relation-merger ref="merger" on-done={mergeDone} />
      <div class="hr"></div>
    </div>

    <div if={filteredRecords && !filteredRecords.length}>
      {tcap('objects.none_found', {interpolations: {o: 'activerecord.models.relation.other'}})}
    </div>

    <table
      class="kor_table text-left"
      each={records, schema in groupedResults}
    >
      <thead>
        <tr>
          <th>
            {tcap('activerecord.attributes.relation.name')}
            <span if={schema == 'null' || !schema}>
              ({t('no_schema')})
            </span>
            <span if={schema && schema != 'null'}>
              ({tcap('activerecord.attributes.relation.schema')}: {schema})
            </span>
          </th>
          <th>
            {tcap('activerecord.attributes.relation.from_kind_id')}<br />
            {tcap('activerecord.attributes.relation.to_kind_id')}
          </th>
          <th if={isRelationAdmin()}></th>
        </tr>
      </thead>
      <tbody>
        <tr each={relation in records}>
          <td>
            <a href="#/relations/{relation.id}/edit">
              {relation.name} / {relation.reverse_name}
            </a>
          </td>
          <td>
            <div if={kindLookup}>
              <span class="label">
                {tcap('activerecord.attributes.relationship.from_id')}:
              </span>
              {kind(relation.from_kind_id)}
            </div>
            <div if={kindLookup}>
              <span class="label">
                {tcap('activerecord.attributes.relationship.to_id')}:
              </span>
              {kind(relation.to_kind_id)}
            </div>
          </td>
          <td class="text-right buttons" if={isRelationAdmin()}>
            <a
              href="#/relations/{relation.id}/edit"
              title={t('verbs.edit')}
            ><i class="pen"></i></a>
            <a
              if={merge}
              href="#"
              onclick={addToMerge}
              title={t('add_to_merge')}
            ><i class="fa fa-compress"></i></a>
            <a
              href="#"
              onclick={invert}
              title={t('verbs.invert')}
            ><i class="fa fa-exchange"></i></a>
            <a href="#/relations/{relation.id}"><i class="fa fa-edit"></i></a>
            <a
              if={relation.removable}
              href="#/relations/{relation.id}"
              onclick={delete(relation)}
              title={t('verbs.delete')}
            ><i class="fa fa-remove"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', -> 
      fetch()
      fetchKinds()

    tag.filters = {}

    tag.delete = (kind) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm tag.t('confirm.general')
          Zepto.ajax(
            type: 'DELETE'
            url: "/relations/#{kind.id}"
            success: -> fetch()
          )

    tag.submit = ->
      tag.filters.terms = tag.formFields['terms'].val()
      tag.filters.hideAbstract = tag.formFields['hideAbstract'].val()
      filter_records()
      groupAndSortRecords()
      tag.update()

    tag.delayedSubmit = (event) ->
      if tag.delayedTimeout
        tag.delayedTimeout.clearTimeout 
        tag.delayedTimeout = undefined
      tag.delayedTimeout = window.setTimeout(tag.submit, 300)
      true

    tag.toggleMerge = (event) ->
      event.preventDefault()
      tag.merge = !tag.merge

    tag.addToMerge = (event) ->
      event.preventDefault();
      tag.refs.merger.addRelation(event.item.relation)

    tag.mergeDone = ->
      tag.merge = false
      fetch()

    tag.invert = (event) ->
      event.preventDefault()
      relation = event.item.relation
      if window.confirm(tag.t('confirm.long_time_warning'))
        Zepto.ajax(
          type: 'PUT'
          url: '/relations/' + relation.id + '/invert'
          success: (data) -> fetch()
        )

    filter_records = ->
      tag.filteredRecords = if tag.filters.terms
        re = new RegExp("#{tag.filters.terms}", 'i')
        results = []
        for relation in tag.data.records
          if relation.name.match(re) || relation.reverse_name.match(re)
            if results.indexOf(relation) == -1
              results.push(relation)
        results
      else
        tag.data.records

    typeCompare = (x, y) ->
      if x.match(/^P\d+/) && y.match(/^P\d+/)
        x = parseInt(x.replace(/^P/, '').split(' ')[0])
        y = parseInt(y.replace(/^P/, '').split(' ')[0])
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

    tag.kind = (id) -> tag.kindLookup[id].name

    fetch = ->
      Zepto.ajax(
        url: '/relations'
        data: {include: 'inheritance'}
        success: (data) ->
          tag.data = data
          filter_records()
          groupAndSortRecords()
          tag.refs.merger.reset()
          tag.update()
      )

    fetchKinds = ->
      Zepto.ajax(
        url: '/kinds'
        success: (data) ->
          tag.kindLookup = {}
          for k in data.records
            tag.kindLookup[k.id] = k
          tag.update()
      )

  </script>

</kor-relations>