<kor-relation-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.relation'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.relation'}})}
      </h1>

      <form onsubmit={submit} if={relation && possible_parents}>
        <kor-input
          name="lock_version"
          value={relation.lock_version || 0}
          ref="fields"
          type="hidden"
        />

        <kor-input
          name="schema"
          label={tcap('activerecord.attributes.relation.schema')}
          ref="fields"
        />

        <kor-input
          name="identifier"
          label={tcap('activerecord.attributes.relation.identifier')}
          riot-value={relation.identifier}
          errors={errors.identifier}
          ref="fields"
          help={tcap('help.relation_identifier')}
        />

        <kor-input
          name="reverse_identifier"
          label={tcap('activerecord.attributes.relation.reverse_identifier')}
          riot-value={relation.reverse_identifier}
          errors={errors.reverse_identifier}
          ref="fields"
          help={tcap('help.relation_identifier')}
        />
        
        <kor-input
          name="name"
          label={tcap('activerecord.attributes.relation.name')}
          riot-value={relation.name}
          errors={errors.name}
          ref="fields"
        />

        <kor-input
          name="reverse_name"
          label={tcap('activerecord.attributes.relation.reverse_name')}
          riot-value={relation.reverse_name}
          errors={errors.reverse_name}
          ref="fields"
        />

        <kor-input
          name="description"
          type="textarea"
          label={tcap('activerecord.attributes.relation.description')}
          riot-value={relation.description}
          ref="fields"
        />

        <kor-input
          if={possible_kinds}
          name="from_kind_id"
          type="select"
          options={possible_kinds}
          label={tcap('activerecord.attributes.relation.from_kind_id')}
          riot-value={relation.from_kind_id}
          errors={errors.from_kind_id}
          ref="fields"
        />

        <kor-input
          if={possible_kinds}
          name="to_kind_id"
          type="select"
          options={possible_kinds}
          label={tcap('activerecord.attributes.relation.to_kind_id')}
          riot-value={relation.to_kind_id}
          errors={errors.to_kind_id}
          ref="fields"
        />

        <kor-input
          name="parent_ids"
          type="select"
          options={possible_parents}
          multiple={true}
          label={tcap('activerecord.attributes.relation.parent')}
          riot-value={relation.parent_ids}
          errors={errors.parent_ids}
          ref="fields"
        />

        <kor-input
          name="abstract"
          type="checkbox"
          label={tcap('activerecord.attributes.relation.abstract')}
          riot-value={relation.abstract}
          ref="fields"
        />

        <div class="hr"></div>

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.page)

    tag.on 'before-mount', ->
      if !tag.isRelationAdmin()
        wApp.bus.trigger('access-denied')

    tag.on 'mount', ->
      tag.errors = {}
      if tag.opts.id
        fetch()
      else
        tag.relation = {}
        tag.update()
      fetchPossibleParents()
      fetchPossibleKinds()

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.done (data) ->
        tag.errors = {}
        window.history.back()
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: '/relations'
        data: JSON.stringify(relation: values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/relations/#{tag.opts.id}"
        data: JSON.stringify(relation: values())
      )

    values = ->
      # TODO: add lock version functionality to all forms
      result = {}
      for field in tag.refs['fields']
        result[field.name()] = field.value()
      result

    fetch = ->
      Zepto.ajax(
        url: "/relations/#{tag.opts.id}"
        data: {include: 'inheritance,technical'}
        success: (data) ->
          tag.relation = data
          tag.update()
      )

    fetchPossibleParents = ->
      Zepto.ajax(
        url: '/relations'
        success: (data) ->
          tag.possible_parents = []
          for relation in data.records
            if parseInt(tag.opts.id) != relation.id
              tag.possible_parents.push(
                label: relation.name
                value: relation.id
              )
          tag.update()
      )

    fetchPossibleKinds = ->
      Zepto.ajax(
        url: '/kinds'
        success: (data) ->
          tag.possible_kinds = []
          for kind in data.records
            tag.possible_kinds.push(
              label: kind.name,
              value: kind.id
            )
          tag.update()
      )

  </script>
</kor-relation-editor>