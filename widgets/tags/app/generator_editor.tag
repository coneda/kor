<kor-generator-editor>

  <h2 if={opts.id}>
    {tcap('objects.edit', {interpolations: {o: 'activerecord.models.generator'}})}
  </h2>
  <h2 if={!opts.id}>
    {tcap('objects.create', {interpolations: {o: 'activerecord.models.generator'}})}
  </h2>

  <form if={data} onsubmit={submit}>
    <kor-input
      name="name"
      label={tcap('activerecord.attributes.generator.name')}
      riot-value={data.name}
      errors={errors.name}
      ref="fields"
    />

    <kor-input
      name="directive"
      label={tcap('activerecord.attributes.generator.directive')}
      help={tcap('help.generator_directive')}
      type="textarea"
      riot-value={data.directive}
      errors={errors.directive}
      ref="fields"
    />

    <div class="hr"></div>

    <kor-input type="submit" />
  </form>


  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.errors = {}

    tag.on 'mount', ->
      if tag.opts.id
        fetch()
      else
        tag.data = {}
        tag.update()

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.done (data) ->
        tag.errors = {}
        tag.opts.notify.trigger 'refresh'
        route("/kinds/#{tag.opts.kindId}/edit")
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: "/kinds/#{tag.opts.kindId}/generators"
        data: JSON.stringify(values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/kinds/#{tag.opts.kindId}/generators/#{tag.opts.id}"
        data: JSON.stringify(values())
      )

    values = ->
      results = {}
      for k, t of tag.refs.fields
        results[t.name()] = t.value()
      return {generator: results}

    fetch = ->
      Zepto.ajax(
        url: "/kinds/#{tag.opts.kindId}/generators/#{tag.opts.id}"
        success: (data) ->
          tag.data = data
          tag.update()
      )

  </script>

</kor-generator-editor>