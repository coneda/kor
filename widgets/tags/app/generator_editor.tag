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
      errors={generator.errors.name}
    />

    <kor-field
      field-id="directive"
      label-key="generator.directive"
      type="textarea"
      model={generator}
      errors={generator.errors.show_label}
    />

    <div class="hr"></div>

    <kor-submit />
  </form>


  <script type="text/coffee">
    tag = this

    tag.opts.notify.on 'add-generator', ->
      console.log 'here'
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

    params = ->
      results = {}
      for k, t of tag.formFields
        results[t.fieldId()] = t.val()
      return {
        generator: results
      }


    create = ->
      Zepto.ajax(
        type: 'POST'
        url: "/kinds/#{tag.opts.kind.id}/generators"
        data: JSON.stringify(params())
        success: ->
          tag.opts.notify.trigger 'refresh'
          tag.showForm = false
        error: (request) ->
          tag.generator = request.responseJSON.record
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

  </script>

</kor-generator-editor>