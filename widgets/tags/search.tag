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

  <style type="text/scss">
    kor-search, [data-is='kor-search'] {
      .allnone {
        margin-right: 1rem;
        margin-top: -3px;
      }
    }
  </style>

  <script type="text/coffee">
    self = this
    window.x = this
    self.params = {}
    
    self.on 'mount', ->
      $.ajax(
        type: 'get'
        url: "#{kor.url}/kinds"
        success: (data) ->
          self.kinds = data
          self.update()
      )

      $.ajax(
        type: 'get'
        url: "#{kor.url}/collections"
        success: (data) ->
          self.collections = data
          self.update()
      )

      self.url_to_params()
      self.update()

    self.kor.bus.on 'query.data', ->
      self.url_to_params()
      self.update()

    self.is_kind_checked = (kind) ->
      self.params['kind_ids'] == undefined ||
      self.params['kind_ids'].indexOf(kind.id) > -1
    self.is_collection_checked = (collection) ->
      self.params['collection_ids'] == undefined ||
      self.params['collection_ids'].indexOf(collection.id) > -1
    self.url_to_params = ->
      self.params = self.kor.routing.state.get()
      self.load_fields()
      self.update()
    self.form_to_url = ->
      kind_ids = []
      for cb in $(self.root).find('.kinds input[type=checkbox]:checked')
        kind_ids.push parseInt($(cb).val())
      collection_ids = []
      for cb in $(self.root).find('.collections input[type=checkbox]:checked')
        collection_ids.push parseInt($(cb).val())
      dataset = {}
      for i in $(self.root).find('input.form-field')
      self.kor.routing.state.update(
        terms: $(x.root).find('[name=terms]').val()
        collection_ids: collection_ids
        kind_ids: kind_ids
      )
    self.load_fields = ->
      if self.params.kind_ids.length == 1
        id = self.params.kind_ids[0]
        $.ajax(
          type: 'get'
          url: "#{kor.url}/kinds/#{id}/fields"
          success: (data) ->
            console.log data
            self.fields = data
            self.update()
        )
      else
        self.fields = []

    self.allnone = (event) ->
      event.preventDefault()
      boxes = $(event.target).parent().find('input[type=checkbox]')
      for box in boxes
        if !$(box).is(':checked')
          boxes.prop 'checked', true
          self.form_to_url()
          return
      boxes.prop 'checked', null
      self.form_to_url()

  </script>

</kor-search>