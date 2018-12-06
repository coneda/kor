<kor-kind-general-editor>
  <h2>{tcap('general')}</h2>

  <div><!-- TODO: figure out why this has to be here -->
    <form if={data && possibleParents} onsubmit={submit}>
      <kor-input
        name="lock_version"
        value={data.lock_version || 0}
        ref="fields"
        type="hidden"
      />

      <kor-input
        name="schema"
        label={tcap('activerecord.attributes.kind.schema')}
        riot-value={data.schema}
        ref="fields"
      />
      
      <kor-input
        name="name"
        label={tcap('activerecord.attributes.kind.name')}
        riot-value={data.name}
        errors={errors.name}
        ref="fields"
      />

      <kor-input
        name="plural_name"
        label={tcap('activerecord.attributes.kind.plural_name')}
        riot-value={data.plural_name}
        errors={errors.plural_name}
        ref="fields"
      />

      <kor-input
        name="description"
        type="textarea"
        label={tcap('activerecord.attributes.kind.description')}
        riot-value={data.description}
        ref="fields"
      />

      <kor-input
        name="url"
        label={tcap('activerecord.attributes.kind.url')}
        riot-value={data.url}
        ref="fields"
      />

      <kor-input
        name="parent_ids"
        type="select"
        options={possibleParents}
        multiple={true}
        label={tcap('activerecord.attributes.kind.parent')}
        riot-value={data.parent_ids}
        errors={errors.parent_ids}
        ref="fields"
      />

      <kor-input
        name="abstract"
        type="checkbox"
        label={tcap('activerecord.attributes.kind.abstract')}
        riot-value={data.abstract}
        ref="fields"
      />

      <kor-input
        name="tagging"
        type="checkbox"
        label={tcap('activerecord.attributes.kind.tagging')}
        riot-value={data.tagging}
        ref="fields"
      />

      <div if={!isMedia()}>
        <kor-input
          name="dating_label"
          label={tcap('activerecord.attributes.kind.dating_label')}
          riot-value={data.dating_label}
          ref="fields"
        />

        <kor-input
          name="name_label"
          label={tcap('activerecord.attributes.kind.name_label')}
          riot-value={data.name_label}
          ref="fields"
        />

        <kor-input
          name="distinct_name_label"
          label={tcap('activerecord.attributes.kind.distinct_name_label')}
          riot-value={data.distinct_name_label}
          ref="fields"
        />
      </div>

      <div class="hr"></div>

      <kor-input
        type="submit"
        value={tcap('verbs.save')}
      />
    </form>
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'mount', ->
      tag.errors = {}
      fetch()

    tag.isMedia = ->
      tag.opts.id && (tag.opts.id == wApp.info.data.medium_kind_id)

    tag.new_record = -> !(tag.data || {}).id

    tag.values = ->
      result = {}
      for field in tag.tags['kor-input']
        result[field.name()] = field.value()
      result

    success = (data) ->
      route("/kinds/#{data.id}/edit")
      wApp.bus.trigger 'reload-kinds'
      tag.errors = {}
      tag.update()

    error = (response) ->
      data = JSON.parse(response.response)
      tag.errors = data.errors
      tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      if tag.new_record()
        Zepto.ajax(
          type: 'POST'
          url: '/kinds'
          data: JSON.stringify(kind: tag.values())
          success: success
          error: error
        )
      else
        Zepto.ajax(
          type: 'PATCH'
          url: "/kinds/#{tag.data.id}"
          data: JSON.stringify(kind: tag.values())
          success: success
          error: error
        )

    # TODO: fetch new action if there was no id to get a formal empty attribute
    # set from the server
    fetch = ->
      if tag.opts.id
        Zepto.ajax(
          url: "/kinds/#{tag.opts.id}"
          data: {include: 'all'}
          success: (data) ->
            tag.data = data
            tag.update()
            fetchPossibleParents()
        )
      else
        tag.data = {}
        fetchPossibleParents()

    fetchPossibleParents = ->
      Zepto.ajax(
        url: '/kinds'
        success: (data) ->
          tag.possibleParents = []
          for kind in data.records
            if !tag.data || (tag.data.id != kind.id && tag.data.id != 1)
              tag.possibleParents.push(
                label: kind.name
                value: kind.id
              )
          tag.update()
      )

  </script>

</kor-kind-general-editor>