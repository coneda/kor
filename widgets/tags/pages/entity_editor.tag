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
          name="lock_version"
          value={data.lock_version || 0}
          ref="fields"
          type="hidden"
        />

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

        <div class="hr"></div>

        <virtual if={!isMedium()}>
          <kor-input
            label={tcap('activerecord.attributes.entity.naming_options')}
            name="no_name_statement"
            type="radio"
            ref="fields.no_name_statement"
            value={data.no_name_statement}
            options={noNameStatements}
            onchange={update}
            errors={errors.no_name_statement}
            help={tcap('help.no_name_input')}
          />

          <kor-input
            if={hasName()}
            label={nameLabel()}
            name="name"
            ref="fields"
            value={data.name}
            errors={errors.name}
            wikidata={config().wikidata_integration}
          />

          <kor-input
            if={hasName()}
            label={distinctNameLabel()}
            name="distinct_name"
            ref="fields"
            value={data.distinct_name}
            errors={errors.distinct_name}
          />

          <div class="hr"></div>
        </virtual>

        <kor-input
          label={tcap('activerecord.attributes.entity.subtype')}
          name="subtype"
          ref="fields"
          value={data.subtype}
          errors={errors.subtype}
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.tag_list')}
          name="tag_list"
          ref="fields"
          value={data.tags.join(', ')}
          errors={errors.tag_list}
        />

        <kor-dataset-fields
          if={kind}
          name="dataset"
          fields={kind.fields}
          values={data.dataset}
          ref="fields"
          errors={errors.dataset}
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.comment')}
          name="comment"
          ref="fields"
          type="textarea"
          value={data.comment}
          errors={errors.comment}
        />

        <div class="hr"></div>

        <kor-synonyms-editor
          label={tcap('activerecord.attributes.entity.synonyms')}
          name="synonyms"
          ref="fields"
          value={data.synonyms}
        />

        <div class="hr"></div>

        <kor-datings-editor
          if={kind}
          label={tcap('activerecord.models.entity_dating', {count: 'other'})}
          name="datings_attributes"
          ref="fields"
          value={data.datings}
          errors={errors.datings}
          for="entity"
          kind={kind}
          default-dating-label={kind.dating_label}
        />

        <div class="hr"></div>

        <kor-entity-properties-editor
          label={tcap('activerecord.attributes.entity.properties')}
          name="properties"
          errors={errors.properties}
          ref="fields"
          value={data.properties}
        />

        <div class="hr"></div>

        <div class="buttons">
          <kor-input type="submit" />
        </div>
      </form>
    </div>
  </div>

  <!-- <div class="kor-layout-left kor-layout-large"></div> -->

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.page)
    tag.mixin(wApp.mixins.config)

    tag.on 'before-mount', ->
      tag.errors = {}
      tag.dating_errors = []

      tag.noNameStatements = [
        {label: tag.t('values.no_name_statements.unknown'), value: 'unknown'},
        {label: tag.t('values.no_name_statements.not_available'), value: 'not_available'},
        {label: tag.t('values.no_name_statements.empty_name'), value: 'empty_name'},
        {label: tag.t('values.no_name_statements.enter_name'), value: 'enter_name'}
      ]

      wApp.bus.on 'wikidata-item-selected', wikidataItemSelected
      wApp.bus.on 'existing-entity-selected', existingEntitySelected

    tag.on 'mount', ->
      checkPermissions()

      fetchCollections()
      wApp.bus.on 'routing:query', queryHandler
      fetch(tag.opts.kindId)

    tag.on 'unmount', ->
      wApp.bus.off 'existing-entity-selected', existingEntitySelected
      wApp.bus.off 'wikidata-item-selected', wikidataItemSelected
      wApp.bus.off 'routing:query', queryHandler

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.then (data) ->
        tag.errors = {}
        id = tag.opts.id || data.id
        wApp.routing.path('/entities/' + id)
      p.catch (response) ->
        tag.errors = response.data.errors
        wApp.utils.scrollToTop()
      p.finally -> tag.update()

    tag.isMedium = ->
      kindId = parseInt(tag.data['kind_id']) || tag.opts.kindId
      kindId == wApp.info.data.medium_kind_id

    tag.hasName = ->
      field = tag.refs['fields.no_name_statement']
      !!field && field.value() == 'enter_name'

    tag.nameLabel = ->
      return '' unless tag.kind
      wApp.utils.capitalize tag.kind.name_label

    tag.distinctNameLabel = ->
      return '' unless tag.kind
      wApp.utils.capitalize tag.kind.distinct_name_label


    checkPermissions = ->
      policy = if tag.opts.id then 'edit' else 'create'
      if tag.currentUser().permissions.collections[policy].length == 0
        wApp.bus.trigger('access-denied')

    queryHandler = (parts = {}) ->
      fetch parts['hash_query']['kind_id']

    defaults = (kind_id) ->
      return {
        kind_id: kind_id
        no_name_statement: 'enter_name'
        lock_version: 0
        tags: [],
        datings: []
      }

    fetch = (kindId) ->
      if tag.opts.id
        Zepto.ajax(
          url: "/entities/#{tag.opts.id}"
          data: {include: 'dataset,synonyms,properties,datings'}
          success: (data) ->
            tag.data = data
            fetchKind()
        )
      else
        if tag.opts.cloneId
          fetchClone()
        else
          tag.data = {
            kind_id: kindId,
            no_name_statement: 'enter_name',
            tags: []
          }
          fetchKind()

    fetchKind = ->
      Zepto.ajax(
        url: "/kinds/#{tag.data['kind_id'] || tag.opts.kindId}"
        data: {include: 'fields,settings'}
        success: (data) ->
          tag.kind = data
          tag.update()
      )

    fetchCollections = ->
      Zepto.ajax(
        url: "/collections",
        data: {per_page: 'max'},
        success: (data) ->
          tag.collections = data.records
          tag.update()
      )

    fetchClone = ->
      Zepto.ajax(
        url: '/entities/' + tag.opts.cloneId + '?include=all'
        success: (data) ->
          for d in data.datings
            delete d.id

          tag.data = data
          fetchKind()
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
      if !tag.isMedium()
        results.no_name_statement = tag.refs['fields.no_name_statement'].value()
      results.kind_id = tag.data.kind_id || tag.opts.kindId
      for f in tag.refs.fields
        results[f.name()] = f.value()
      results

    wikidataItemSelected = (item) ->
      inputByName('name').set(item.name);
      inputByName('comment').set(item.description);
      if t = inputByName('dataset').inputByName('wikidata_id')
        t.set(item.id)

    existingEntitySelected = (entity) ->
      # console.log(arguments);
      wApp.routing.path('/entities/' + entity.id);

    inputByName = (name) ->
      for f in tag.refs.fields
        if f.name() == name
          return f
      null

  </script>

</kor-entity-editor>
