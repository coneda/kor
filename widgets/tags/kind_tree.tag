<kor-kind-tree>

  <form onsubmit={submit} class="kor-horizontal">
    <kor-field
      label-key="search_term"
      field-id="terms"
    />

    <kor-field
      label-key="hide_abstract"
      type="checkbox"
      field-id="hideAbstract"
    />

    <div class="hr"></div>

    <kor-submit label-key="verbs.search" />
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

  <style type="text/scss">
    kor-kind-tree, [data-is=kor-kind-tree] {
      display: block;
      padding: 1rem;

      td {
        .icon {
          float: right;
          margin-left: 0.5rem;
        }
      }

      td.parent {
        background-color: lighten(#1e1e1e, 10%) !important;
      }

      td.self {
        background-color: lighten(#1e1e1e, 20%) !important;
      }
    }
  </style>

  <script type="text/coffee">
    tag = this
    tag.filters = {}

    tag.on 'mount', -> fetch()
    wApp.bus.on 'kinds-changed', -> fetch()

    tag.add = ->
      wApp.bus.trigger 'modal', 'kor-kind-editor'

    tag.edit = (kind) ->
      (event) ->
        wApp.bus.trigger 'modal', 'kor-kind-editor', kind: kind

    tag.delete = (kind) ->
      (event) ->
        if wApp.utils.confirm wApp.i18n.translate('confirm.general')
          $.ajax(
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

    tag.submit = (event) ->
      event.preventDefault()
      tag.filters.terms = tag.tags['kor-field'][0].val()
      tag.filters.hideAbstract = tag.tags['kor-field'][1].val()
      filter_records()
      group_records()

    ancestry_for = (kind) ->
      results = [kind]
      for parent_id in kind.parent_ids
        results = results.concat ancestry_for(tag.lookup[parent_id])
      results

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
            # for kind in ancestry_for(kind)
            #   if results.indexOf(kind) == -1
            #     results.push(kind)
        results
      else
        tag.data.records

      if tag.filters.hideAbstract
        tag.filtered_records = tag.filtered_records.filter (kind) -> !kind.abstract


    group_records = ->
      tag.grouped_records = wApp.utils.in_groups_of(5, tag.filtered_records)

    # render_graph = ->
      # nodes = []
      # edges = []
      # for kind in tag.filtered_records
      #   kind.label = kind.name
      #   kind.group = 'real' if !kind.abstract
      #   nodes.push(kind)
      #   for parent_id in kind.parent_ids
      #     edges.push(to: kind.id, from: parent_id)
      # data = {
      #   nodes: new vis.DataSet(nodes)
      #   edges: new vis.DataSet(edges)
      # }

      # window.h = tag

      # tag.r = d3.hierarchy {}, (kind) ->
      #   if kind.child_ids
      #     for child_id in kind.child_ids
      #       tag.lookup[child_id]
      #   else
      #     tag.roots

      # c = d3.cluster()
      # c(tag.r)

      # svg = d3.select(".kor-graph").append("svg").
      #   attr('width', '100%').attr('height', 2000).attr('overflow', 'visible')

      # t = (obj) -> 
      #   # console.log [obj.y * 600 + 10, obj.x * 800]
      #   [obj.y * 600 + 10, obj.x * 2000]
      # tt = (obj) -> t(obj).join(',')

      # position = (d) -> "translate(#{tt(d)})"

      # svg.selectAll('circle').
      #   data(tag.r.descendants()).
      #   enter().
      #   append('circle').attr('r', 10).attr('fill', '#f00').
      #   attr('transform', position)

      # # diagonal = d3.diagonal().projection((d) -> [d.y, d.x])

      # # console.log tag.r.links()

      # svg.selectAll('path').
      #   data(tag.r.links()).
      #   enter().
      #   insert("path", "g").
      #   attr('stroke', '#f00').
      #   attr("d", (d) ->
      #     start = t(d.source)
      #     end = t(d.target)
      #     path = d3.path()
      #     console.log start, end
      #     path.moveTo(start[0], start[1])
      #     path.lineTo(end[0], end[1])
      #     console.log path.toString()
      #     path.toString()
      #   )

      # if tag.network
      #   tag.network.setData(data)
      # else
      #   container = $(tag.root).find('.kor-graph')[0]
      #   tag.network = new vis.Network(container, data,
      #     interaction: {
      #       # zoomView: false
      #     }
      #     physics: {
      #       enabled: false
      #       hierarchicalRepulsion: {
      #         # nodeDistance: 400
      #       }
      #       barnesHut: {
      #         avoidOverlap: 0.5
      #       }
      #     }
      #     layout: {
      #       randomSeed: 43028
      #       improvedLayout: true
      #       # hierarchical: {
      #       #   enabled: true
      #       #   edgeMinimization: true
      #       #   levelSeparation: 400
      #       #   # nodeSpacing: 200
      #       #   blockShifting: true
      #       #   sortMethod: 'directed'
      #       #   direction: 'LR'
      #       #   parentCentralization: false
      #       # }
      #     }
      #     nodes: {
      #       shape: 'box'
      #       labelHighlightBold: false
      #       color: {
      #         highlight: '#565656'
      #         background: '#1E1E1E'
      #         border: '#ffffff'
      #       }
      #       font: {
      #         color: '#ffffff'
      #         size: 20
      #         face: 'verdana'
      #       }
      #     }
      #     edges: {
      #       physics: false
      #       arrows: {
      #         to: {
      #           enabled: true
      #         }
      #       }
      #       color: {
      #         color: '#ffffff'
      #       }
      #     }
      #     groups: {
      #       real: {
      #         color: {
      #           background: 'blue'
      #         }
      #       }
      #     }
      #   )

      # console.log tag.network.getScale()

    fetch = ->
      # console.log 'fetching'
      $.ajax(
        type: 'get'
        url: '/kinds'
        success: (data) ->
          tag.data = data
          index_records()
          filter_records()
          group_records()
          tag.update()
      )

    # tag.has_children = -> tag.opts.kind.children_count > 0
    # tag.expand = (event) -> tag.toggle event, true
    # tag.collapse = (event) -> tag.toggle event, false
    # tag.toggle = (event, force = undefined) ->
    #   event.preventDefault() if event
    #   tag.expanded = (if force == undefined then !tag.expanded else force)
    #   tag.update()
  </script>

</kor-kind-tree>