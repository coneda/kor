<kor-relation-editor>

  <kor-layout-panel class="left large">
    <kor-panel>
      <h1>
        <span show={opts.id} if={relation}>{relation.name}</span>
        <span show={!opts.id}>
          {
            wApp.i18n.t('objects.create', {
              'interpolations': {
                'o': wApp.i18n.t('activerecord.models.relation')
              }
            })
          }
        </span>
      </h1>

      <form onsubmit={submit} if={relation && possible_parents}>
        
        <kor-field
          field-id="name"
          label-key="relation.name"
          model={relation}
          errors={errors.name}
        />

        <kor-field
          field-id="reverse_name"
          label-key="relation.reverse_name"
          model={relation}
          errors={errors.reverse_name}
        />

        <kor-field
          field-id="description"
          type="textarea"
          label-key="relation.description"
          model={relation}
        />

        <kor-field
          if={possible_kinds}
          field-id="from_kind_ids"
          type="select"
          options={possible_kinds}
          multiple={true}
          label-key="relation.from_kind_ids"
          model={relation}
          errors={errors.from_kind_ids}
        />

        <kor-field
          if={possible_kinds}
          field-id="to_kind_ids"
          type="select"
          options={possible_kinds}
          multiple={true}
          label-key="relation.to_kind_ids"
          model={relation}
          errors={errors.to_kind_ids}
        />

        <kor-field
          field-id="parent_ids"
          type="select"
          options={possible_parents}
          multiple={true}
          label-key="relation.parent"
          model={relation}
          errors={errors.parent_ids}
        />

        <kor-field
          field-id="abstract"
          type="checkbox"
          label-key="relation.abstract"
          model={relation}
        />

        <div class="hr"></div>

        <kor-submit />

      </form>
    </kor-panel>
  </kor-layout-panel>

  <script type="text/coffee">
    tag = this
    window.t = tag

    tag.on 'mount', ->
      tag.errors = {}
      if tag.opts.id
        fetch()
      else
        tag.relation = {}
        tag.update()
      fetchPossibleParents()
      fetchPossibleKinds()

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
        type: 'get'
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

    tag.new_record = -> !tag.opts.id

    tag.values = ->
      result = {lock_version: tag.relation.lock_version}
      for field in tag.tags['kor-field']
        result[field.fieldId()] = field.val()
      result

    success = (data) ->
      window.location.hash = '/relations'
      tag.errors = {}
      tag.update()

    error = (response) ->
      data = JSON.parse(response.response)
      tag.errors = data.errors
      tag.relation = data.record
      tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      if tag.new_record()
        Zepto.ajax(
          type: 'POST'
          url: '/relations'
          data: JSON.stringify(relation: tag.values())
          success: success
          error: error
        )
      else
        Zepto.ajax(
          type: 'PATCH'
          url: "/relations/#{tag.opts.id}"
          data: JSON.stringify(relation: tag.values())
          success: success
          error: error
        )

  </script>


</kor-relation-editor>