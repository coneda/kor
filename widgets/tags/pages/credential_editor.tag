<kor-credential-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.credential'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.credential'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.credential.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <kor-input
          label={tcap('activerecord.attributes.credential.description')}
          name="description"
          type="textarea"
          ref="fields"
          value={data.description}
          errors={errors.description}
        />

        <hr />

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.page)

    tag.on 'before-mount', ->
      tag.errors = {}
      tag.data = {}

    tag.on 'mount', ->
      fetch() if tag.opts.id

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.done (data) ->
        tag.errors = {}
        window.history.back()
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    fetch = ->
      Zepto.ajax(
        url: "/credentials/#{tag.opts.id}"
        success: (data) ->
          tag.data = data
          tag.update()
      )

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: '/credentials'
        data: JSON.stringify(credential: values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/credentials/#{tag.opts.id}"
        data: JSON.stringify(credential: values())
      )

    values = ->
      results = {}
      for f in tag.refs.fields
        results[f.name()] = f.value()
      results

  </script>
</kor-credential-editor>