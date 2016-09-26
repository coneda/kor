<kor-kind-tree>

  <form onsubmit={submit}>
    <kor-field
      field-id="terms"
    />

    <kor-field type="submit" />
  </form>

  <div class="kor-graph"></div>

  <!-- <a href="#" onclick={toggle} show={opts.kind.id && has_children()}>
    <i show={!expanded} class="fa fa-chevron-right"></i>
    <i show={expanded} class="fa fa-chevron-down"></i>
  </a>

  <div class="content">
    <div class="name" show={opts.kind.id}>
      <a href="#" onclick={edit(opts.kind)}>
        {opts.kind.name}/{opts.kind.plural_name}
        <i class="fa fa-edit"></i>
      </a>
      <a href="#" onclick={delete(opts.kind)}>
        <i class="fa fa-remove"></i>
      </a>
    </div>

    <ul show={!opts.kind.id || (expanded && opts.kind.children)}>
      <li each={child in opts.kind.children}>
        <kor-kind-tree kind={child} />
      </li>
    </ul>
  </div> -->

  <!-- <div class="clearfix"></div> -->

  <style type="text/scss">
    .kor-graph {
      height: 600px;
    }
  </style>

  <script type="text/coffee">
    tag = this
    tag.mixin 'bubble'
    tag.expanded = true
    tag.filters = {}

    tag.on 'mount', ->
      tag.on 'expand-all', tag.expand
      tag.parent.on 'expand-all', -> tag.trigger 'expand-all'
      tag.on 'collapse-all', tag.collapse
      tag.parent.on 'collapse-all', -> tag.trigger 'collapse-all'

      unless tag.opts.kind
        tag.expanded = true
        fetch()

    tag.submit = (event) ->
      event.preventDefault()
      console.log "bla"
      tag.filters.terms = tag.tags['kor-field'][0].val()
      render_graph()

    filtered_records = ->
      results = []

      for kind in tag.data.records
        if t = tag.filters.terms
          re = new RegExp("#{t}")
          if kind.name.match(re)
            k = kind
            while k
              unless results.indexOf(k) == -1
                results.push(k)
              k = tag.lookup[k.parent_id]


    render_graph = ->
      nodes = []
      edges = []
      for kind in filtered_records()
        kind.label = kind.name
        kind.group = 'real' if !kind.abstract
        nodes.push(kind)
        if kind.parent_id
          edges.push(to: kind.id, from: kind.parent_id)
      edges.push(from: 929, to: 927)
      data = {
        nodes: new vis.DataSet(nodes)
        edges: new vis.DataSet(edges)
      }

      if tag.network
        tag.network.setData(data)
      else
        container = $(tag.root).find('.kor-graph')[0]
        tag.network = new vis.Network(container, data,
          interaction: {
            # zoomView: false
          }
          physics: {
            enabled: false
            hierarchicalRepulsion: {
              # nodeDistance: 400
            }
          }
          layout: {
            hierarchical: {
              enabled: true
              edgeMinimization: false
              levelSeparation: 400
              # nodeSpacing: 200
              # blockShifting: false
              sortMethod: 'directed'
              direction: 'LR'
            }
          }
          nodes: {
            shape: 'box'
            labelHighlightBold: false
            color: {
              highlight: '#565656'
              background: '#1E1E1E'
              border: '#ffffff'
            }
            font: {
              color: '#ffffff'
              size: 20
              face: 'verdana'
            }
          }
          edges: {
            arrows: {
              to: {
                enabled: true
              }
            }
            color: {
              color: '#ffffff'
            }
          }
          groups: {
            real: {
              color: {
                background: 'blue'
              }
            }
          }
        )

      # console.log tag.network.getScale()

    fetch = ->
      # console.log tag.opts
      if !tag.opts.kind || !tag.opts.kind.children
        $.ajax(
          type: 'get'
          url: '/kinds'
          data: {parent_id: 'all'}
          success: (data) ->
            tag.data = data
            tag.lookup = {}
            for kind in data.records
              tag.lookup[kind.id] = kind
            render_graph()

            # results = []
            # for kind in data.records
            #   if kind.parent_id
            #     lookup[kind.parent_id].children ||= []
            #     lookup[kind.parent_id].children.push(kind)
            #   else
            #     results.push(kind)
            # tag.opts.kind = {children: results}
            tag.update()
        )

    tag.edit = (kind) ->
      (event) ->
        event.preventDefault()
        tag.trigger('kor-kind-edit', kind)
    tag.delete = (kind) ->
      (event) ->
        event.preventDefault()
        tag.trigger('kor-kind-delete', kind)

    tag.has_children = -> tag.opts.kind.children_count > 0
    tag.expand = (event) -> tag.toggle event, true
    tag.collapse = (event) -> tag.toggle event, false
    tag.toggle = (event, force = undefined) ->
      event.preventDefault() if event
      tag.expanded = (if force == undefined then !tag.expanded else force)
      tag.update()
  </script>

</kor-kind-tree>