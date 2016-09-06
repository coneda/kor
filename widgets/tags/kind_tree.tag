<kor-kind-tree>

  <a href="#" onclick={toggle} show={opts.kind.id && has_children()}>
    <i show={!expanded} class="fa fa-chevron-right"></i>
    <i show={expanded} class="fa fa-chevron-down"></i>
  </a>

  <div class="content">
    <span show={opts.kind.id}>{opts.kind.name}/{opts.kind.plural_name}</span>

    <ul show={!opts.kind.id || (expanded && opts.kind.children)}>
      <li each={child in opts.kind.children}>
        <kor-kind-tree kind={child} />
      </li>
    </ul>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this

    tag.on 'mount', ->
      tag.on 'expand-all', tag.expand
      tag.parent.on 'expand-all', -> tag.trigger 'expand-all'
      tag.on 'collapse-all', tag.collapse
      tag.parent.on 'collapse-all', -> tag.trigger 'collapse-all'

      unless tag.opts.kind
        tag.expanded = true
        fetch()

    fetch = (parent_id) ->
      if !tag.opts.kind || !tag.opts.kind.children
        $.ajax(
          type: 'get'
          url: '/kinds'
          data: {parent_id: parent_id}
          success: (data) ->
            tag.opts.kind ||= {}
            tag.opts.kind.children = data.records
            tag.update()
        )

    tag.has_children = -> tag.opts.kind.children_count > 0

    tag.expand = (event) -> tag.toggle event, true
    tag.collapse = (event) -> tag.toggle event, false
    tag.toggle = (event, force = undefined) ->
      event.preventDefault() if event
      tag.expanded = (if force == undefined then !tag.expanded else force)
      fetch(tag.opts.kind.id)
      tag.update()
  </script>

</kor-kind-tree>