<kor-entity-editor>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.entity'}})}
      </h1>
      <h1 if={!opts.id && kind}>
        {tcap('objects.create', {interpolations: {o: kind.name}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          if={collections}
          label={tcap('activerecord.attributes.entity.collection_id')}
          name="collection_id"
          type="select"
          options={collections}
          ref="fields"
          value={data.collection_id}
          errors={errors.collection_id}
        />

        <hr />

        <virtual if={!isMedium()}>
          <kor-input
            label={tcap('activerecord.attributes.entity.name')}
            name="no_name_statement"
            type="radio"
            ref="fields.no_name_statement"
            value={data.no_name_statement}
            options={noNameStatements}
            onchange={update}
            errors={errors.no_name_statement}
          />

          <kor-input
            if={hasName()}
            name="name"
            ref="fields"
            value={data.name}
            errors={errors.name}
          />

          <kor-input
            if={hasName()}
            label={tcap('activerecord.attributes.entity.distinct_name')}
            name="distinct_name"
            ref="fields"
            value={data.distinct_name}
            errors={errors.distinct_name}
          />

          <hr />
        </virtual>


        <kor-input
          label={tcap('activerecord.attributes.entity.subtype')}
          name="subtype"
          ref="fields"
          value={data.subtype}
          errors={errors.subtype}
        />

        <kor-dataset-fields
          if={kind}
          name="dataset"
          fields={kind.fields}
          values={data.dataset}
          ref="fields"
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.comment')}
          name="comment"
          ref="fields"
          type="textarea"
          value={data.comment}
          errors={errors.comment}
        />

        <hr />

        <kor-synonyms-editor
          label={tcap('activerecord.attributes.entity.synonyms')}
          name="synonyms"
          ref="fields"
          value={data.synonyms}
        />

        <hr />

        <kor-datings-editor
          label={tcap('activerecord.models.entity_dating', {count: 'other'})}
          name="datings_attributes"
          ref="fields"
          value={data.datings}
          errors={errors.datings}
        />

        <hr />

        <kor-entity-properties-editor
          label={tcap('activerecord.attributes.entity.properties')}
          name="properties"
          ref="fields"
          value={data.properties}
        />

        <hr />

        <kor-input
          type="submit"
          value={tcap('verbs.save')}
        />

      </form>

    </div>
  </div>

  <!-- <div class="kor-layout-left kor-layout-large"></div> -->

  <div class="clearfix"></div>
 
  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'before-mount', ->
      tag.errors = {}
      tag.dating_errors = []

      tag.data = {no_name_statement: 'enter_name'}

      tag.noNameStatements = [
        {label: tag.t('values.no_name_statements.unknown'), value: 'unknown'},
        {label: tag.t('values.no_name_statements.not_available'), value: 'not_available'},
        {label: tag.t('values.no_name_statements.empty_name'), value: 'empty_name'},
        {label: tag.t('values.no_name_statements.enter_name'), value: 'enter_name'}
      ]

    tag.on 'mount', ->
      fetchCollections()
      wApp.bus.on 'routing:query', queryHandler
      fetch tag.opts.kind_id

    tag.on 'unmount', ->
      wApp.bus.off 'routing:query', queryHandler

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.done (data) ->
        tag.errors = {}
        id = tag.opts.id || data.id
        wApp.routing.path('/entities/' + id)
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    tag.isMedium = ->
      kindId = parseInt(tag.data['kind_id']) || tag.opts.kindId
      kindId == wApp.info.data.medium_kind_id

    tag.hasName = ->
      tag.refs['fields.no_name_statement'] &&
      tag.refs['fields.no_name_statement'].value() == 'enter_name'

    queryHandler = (parts = {}) ->
      fetch parts['hash_query']['kind_id']

    fetch = (kind_id) ->
      if tag.opts.id
        Zepto.ajax(
          url: "/entities/#{tag.opts.id}"
          data: {include: 'dataset,synonyms,properties,datings'}
          success: (data) ->
            tag.data = data
            fetchKind()
        )
      else
        tag.data['kind_id'] = kind_id
        fetchKind()

    fetchKind = ->
      Zepto.ajax(
        url: "/kinds/#{tag.data['kind_id'] || tag.opts.kindId}"
        data: {include: 'fields'}
        success: (data) ->
          tag.kind = data
          tag.update()
      )

    fetchCollections = ->
      Zepto.ajax(
        url: "/collections"
        success: (data) ->
          tag.collections = data.records
          tag.update()
      )

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: '/entities'
        data: JSON.stringify(entity: values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/entities/#{tag.opts.id}"
        data: JSON.stringify(entity: values())
      )

    values = ->
      results = {}
      results.no_name_statement = tag.refs['fields.no_name_statement'].value()
      results.kind_id = tag.data.kind_id || tag.opts.kindId
      for f in tag.refs.fields
        results[f.name()] = f.value()
      results

  </script>

</kor-entity-editor>