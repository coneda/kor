<kor-kind-tree>

  <h1>{t('activerecord.models.kind', {capitalize: true, count: 'other'})}</h1>

  <div class="hr"></div>

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
    <a href="#/kinds/new" onclick={add}>
      <i class="fa fa-plus-square"></i>
    </a>
  </div>

  <table class="kor_table">
    <tr each={row in grouped_records}>
      <td
        each={kind in row}
        class={
          parent: highlight.parents[kind.id],
          self: (highlight.self == kind.id)
        }
        onmouseover={setHighlight(kind)}
      >
        <a
          if={kind.child_ids.length == 0 && !isMedia(kind)}
          href="#/kinds/{kind.id}"
          onclick={delete(kind)}
          class="icon"
        ><i class="fa fa-remove"></i></a>
        <a
          href="#/kinds/{kind.id}"
          onclick={edit(kind)}
        >{kind.name}</a>
      </td>
    </tr>
  </table>

  <script type="text/coffee">
    tag = this
    tag.filters = {}
    tag.bus = riot.observable()

    tag.on 'mount', -> fetch()
    wApp.bus.on 'kinds-changed', -> fetch()

    tag.t = wApp.i18n.translate

    tag.add = ->
      wApp.bus.trigger 'modal', 'kor-kind-editor', notify: tag.bus

    tag.edit = (kind) ->
      (event) ->
        wApp.bus.trigger 'modal', 'kor-kind-editor', kind: kind, notify: tag.bus

    tag.delete = (kind) ->
      (event) ->
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          Zepto.ajax(
            type: 'delete'
            url: "/kinds/#{kind.id}"
            success: ->
              wApp.bus.trigger 'kinds-changed'
          )

    tag.isMedia = (kind) -> kind.uuid == wApp.data.medium_kind_uuid

    tag.setHighlight = (kind) ->
      (event) ->
        tag.highlight = {
          parents: {}
          self: kind.id
        }
        for id in kind.parent_ids
          tag.highlight.parents[id] = true
        tag.update()

    tag.submit = ->
      tag.filters.terms = tag.formFields['terms'].val()
      tag.filters.hideAbstract = tag.formFields['hideAbstract'].val()
      filter_records()
      group_records()
      tag.update()

    tag.delayedSubmit = (event) ->
      if tag.delayedTimeout
        tag.delayedTimeout.clearTimeout 
        tag.delayedTimeout = undefined

      tag.delayedTimeout = window.setTimeout(tag.submit, 300)
      true

    index_records = ->
      tag.lookup = {}
      tag.roots = []
      for kind in tag.data.records
        tag.lookup[kind.id] = kind
        if kind.parent_ids.length == 0
          tag.roots.push(kind)

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


    group_records = ->
      tag.grouped_records = wApp.utils.in_groups_of(5, tag.filtered_records)

    fetch = ->
      Zepto.ajax(
        type: 'get'
        url: '/kinds'
        success: (data) ->
          tag.data = data
          index_records()
          filter_records()
          group_records()
          tag.update()
      )

  </script>

</kor-kind-tree>