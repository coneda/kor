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
            onchange={changed}
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
            <input type="checkbox" value={collection.id} checked="true" />
            {collection.name}
          </label>
        </div>
      </div>

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
              checked="true"
              onchange={changed}
            />
            {kind.plural_name}
          </label>
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

    self.changed = (event) ->
      kind_ids = []
      for cb in $(self.root).find('.kindss input[type=checkbox]')
        if $(cb).is(':checked')
          kind_ids.push cb.attr
      collection_ids = []
      for cb in $(self.root).find('.collections input[type=checkbox]')
        if $(cb).is(':checked')
          collection_ids.push cb.attr
      self.kor.routing.update(
        terms: $(self.terms).val()
        collection_ids: collection_ids
        kinds_ids: kind_ids
      )

    self.allnone = (event) ->
      boxes = $(event.target).parent().find('input[type=checkbox]')
      for box in boxes
        console.log $(box).is(':checked')
        if !$(box).is(':checked')
          console.log boxes
          boxes.prop 'checked', true
          return
      boxes.prop 'checked', null

  </script>

</kor-search>