<kor-kind-tree>

  <a href="#" onclick={toggle} show={opts.kind.id && has_children()}>
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
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin 'bubble'
    tag.expanded = true

    tag.on 'mount', ->
      tag.on 'expand-all', tag.expand
      tag.parent.on 'expand-all', -> tag.trigger 'expand-all'
      tag.on 'collapse-all', tag.collapse
      tag.parent.on 'collapse-all', -> tag.trigger 'collapse-all'

      unless tag.opts.kind
        tag.expanded = true
        fetch()

    fetch = ->
      # console.log tag.opts
      if !tag.opts.kind || !tag.opts.kind.children
        $.ajax(
          type: 'get'
          url: '/kinds'
          data: {parent_id: 'all'}
          success: (data) ->
            lookup = {}
            for kind in data.records
              lookup[kind.id] = kind
            results = []
            for kind in data.records
              if kind.parent_id
                lookup[kind.parent_id].children ||= []
                lookup[kind.parent_id].children.push(kind)
              else
                results.push(kind)
            tag.opts.kind = {children: results}
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