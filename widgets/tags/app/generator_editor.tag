<kor-generator-editor>

  <h2>
    <kor-t
      key="objects.edit"
      with={ {'interpolations': {'o': wApp.i18n.translate('activerecord.models.generator', {count: 'other'})}} }
      show={opts.kind.id}
    />
  </h2>

  <form if={showForm} onsubmit={submit}>

    <kor-field
      field-id="name"
      label-key="generator.name"
      model={generator}
      errors={errors.name}
    />

    <kor-field
      field-id="directive"
      label-key="generator.directive"
      type="textarea"
      model={generator}
      errors={errors.directive}
    />

    <div class="hr"></div>

    <kor-submit />
  </form>


  <script type="text/coffee">
    tag = this
    tag.errors = {}

    tag.opts.notify.on 'add-generator', ->
      tag.generator = {}
      tag.showForm = true
      tag.update()

    tag.opts.notify.on 'edit-generator', (generator) ->
      tag.generator = generator
      tag.showForm = true
      tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      if tag.generator.id then update() else create()

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: "/kinds/#{tag.opts.kind.id}/generators"
        data: JSON.stringify(params())
        success: ->
          tag.opts.notify.trigger 'refresh'
          tag.errors = {}
          tag.showForm = false
        error: (request) ->
          data = JSON.parse(request.response)
          tag.errors = data.record.errors
        complete: ->
          tag.update()
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/kinds/#{tag.opts.kind.id}/generators/#{tag.generator.id}"
        data: JSON.stringify(params())
        success: ->
          tag.opts.notify.trigger 'refresh'
          tag.showForm = false
        error: (request) ->
          tag.generator = request.responseJSON.record
        complete: ->
          tag.update()
      )

    params = ->
      results = {}
      for k, t of tag.formFields
        results[t.fieldId()] = t.val()
      return {generator: results}

  </script>

</kor-generator-editor>