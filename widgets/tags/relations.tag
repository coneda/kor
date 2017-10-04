<kor-relations>

  <h1>
    {wApp.i18n.t('activerecord.models.relation', {capitalize: true, count: 'other'})}
  </h1>

  <form class="kor-horizontal" >

    <kor-field
      label-key="search_term"
      field-id="terms"
      onkeyup={delayedSubmit}
    />

    <div class="hr"></div>
  </form>

  <div class="text-right">
    <a href="#/relations/new">
      <i class="fa fa-plus-square"></i>
    </a>
  </div>

  <div if={filtered_records && !filtered_records.length}>
    {wApp.i18n.t('objects.none_found', {
      interpolations: {o: 'activerecord.models.relation.other'},
      capitalize: true
    })}
  </div>

  <table
    class="kor_table text-left"
    if={filtered_records && filtered_records.length}
  >
    <thead>
      <tr>
        <th>{wApp.i18n.t('activerecord.attributes.relation.name')}</th>
        <th>
          {wApp.i18n.t('activerecord.attributes.relation.from_kind_id')}
          {wApp.i18n.t('activerecord.attributes.relation.to_kind_id')}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr each={relation in filtered_records}>
        <td>
          <a href="#/relations/{relation.id}">
            {relation.name} / {relation.reverse_name}
          </a>
        </td>
        <td>
          <div if={kindLookup}>
            <span class="label">
              {wApp.i18n.t('activerecord.attributes.relationship.from_id')}:
            </span>
            {kind(relation.from_kind_id)}
          </div>
          <div if={kindLookup}>
            <span class="label">
              {wApp.i18n.t('activerecord.attributes.relationship.to_id')}:
            </span>
            {kind(relation.to_kind_id)}
          </div>
        </td>
        <td class="text-right buttons">
          <a href="#/relations/{relation.id}"><i class="fa fa-edit"></i></a>
          <a
            if={relation.removable}
            href="#/relations/{relation.id}"
            onclick={delete(relation)}
          ><i class="fa fa-remove"></i></a>
        </td>
      </tr>
    </tbody>
  </table>

  <script type="text/coffee">
    tag = this
    tag.requireRoles = ['relation_admin']
    tag.mixin(wApp.mixins.session)

    # window.t = tag

    tag.on 'mount', -> 
      fetch()
      fetchKinds()

    tag.filters = {}

    tag.delete = (kind) ->
      (event) ->
        event.preventDefault()
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/relations/#{kind.id}"
            success: -> fetch()
          )

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
        for relation in tag.data.records
          if relation.name.match(re) || relation.reverse_name.match(re)
            if results.indexOf(relation) == -1
              results.push(relation)
        results
      else
        tag.data.records

    tag.kind = (id) -> tag.kindLookup[id].name

    fetch = ->
      Zepto.ajax(
        url: '/relations'
        data: {include: 'inheritance'}
        success: (data) ->
          tag.data = data
          filter_records()
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