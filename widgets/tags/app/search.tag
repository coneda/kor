<kor-search>

  <h1>Search</h1>

  <form class="form">
    <div class="row">
      <div class="col-md-3">
        <div class="form-group">
          <input
            type="text"
            name="terms"
            placeholder="fulltext search ..."
            class="form-control"
            id="kor-search-form-terms"
            onchange={form_to_url}
            value={params.terms}
          />
        </div>
      </div>
    </div>
    <div class="row">
      <div class="col-md-12 collections">
        <button
          class="btn btn-default btn-xs allnone"
          onclick={allnone}
        >all/none</button>

        <div class="checkbox-inline" each={collection in collections}>
          <label>
            <input
              type="checkbox"
              value={collection.id}
              checked={parent.is_collection_checked(collection)}
              onchange={parent.form_to_url}
            />
            {collection.name}
          </label>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-md-12 kinds">
        <button
          class="btn btn-default btn-xs allnone"
          onclick={allnone}
        >all/none</button>

        <div class="checkbox-inline" each={kind in kinds}>
          <label>
            <input
              type="checkbox"
              value={kind.id}
              checked={parent.is_kind_checked(kind)}
              onchange={parent.form_to_url}
            />
            {kind.plural_name}
          </label>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-md-3 kinds" each={field in fields}>
        <div class="form-group">
          <input
            type="text"
            name={field.name}
            placeholder={field.search_label}
            class="kor-dataset-field form-control"
            id="kor-search-form-dataset-{field.name}"
            onchange={parent.form_to_url}
            value={parent.params.dataset[field.name]}
          />
        </div>
      </div>
    </div>
  </form>

  <script type="text/coffee">
    tag = this
    tag.params = {}
    
    # tag.on 'mount', ->
    #   $.ajax(
    #     type: 'get'
    #     url: "#{kor.url}/kinds"
    #     success: (data) ->
    #       tag.kinds = data
    #       tag.update()
    #   )

    #   $.ajax(
    #     type: 'get'
    #     url: "#{kor.url}/collections"
    #     success: (data) ->
    #       tag.collections = data
    #       tag.update()
    #   )

    #   tag.url_to_params()
    #   tag.update()

    # tag.kor.bus.on 'query.data', ->
    #   tag.url_to_params()
    #   tag.update()

    # tag.is_kind_checked = (kind) ->
    #   tag.params['kind_ids'] == undefined ||
    #   tag.params['kind_ids'].indexOf(kind.id) > -1
    # tag.is_collection_checked = (collection) ->
    #   tag.params['collection_ids'] == undefined ||
    #   tag.params['collection_ids'].indexOf(collection.id) > -1
    # tag.url_to_params = ->
    #   tag.params = tag.kor.routing.state.get()
    #   tag.load_fields()
    #   tag.update()
    # tag.form_to_url = ->
    #   kind_ids = []
    #   for cb in $(tag.root).find('.kinds input[type=checkbox]:checked')
    #     kind_ids.push parseInt($(cb).val())
    #   collection_ids = []
    #   for cb in $(tag.root).find('.collections input[type=checkbox]:checked')
    #     collection_ids.push parseInt($(cb).val())
    #   dataset = {}
    #   tag.kor.routing.state.update(
    #     terms: $(x.root).find('[name=terms]').val()
    #     collection_ids: collection_ids
    #     kind_ids: kind_ids
    #   )
    # tag.load_fields = ->
    #   if tag.params.kind_ids.length == 1
    #     id = tag.params.kind_ids[0]
    #     $.ajax(
    #       type: 'get'
    #       url: "#{kor.url}/kinds/#{id}/fields"
    #       success: (data) ->
    #         console.log data
    #         tag.fields = data
    #         tag.update()
    #     )
    #   else
    #     tag.fields = []

    # tag.allnone = (event) ->
    #   event.preventDefault()
    #   boxes = $(event.target).parent().find('input[type=checkbox]')
    #   for box in boxes
    #     if !$(box).is(':checked')
    #       boxes.prop 'checked', true
    #       tag.form_to_url()
    #       return
    #   boxes.prop 'checked', null
    #   tag.form_to_url()

  </script>

</kor-search>