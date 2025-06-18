<kor-collection-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.collection'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.collection'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.collection.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <virtual if={credentials}>
          <div class="hr"></div>

          <kor-input
            each={policy in policies}
            label={tcap('activerecord.attributes.collection.' + policy)}
            name={policy}
            type="select"
            multiple={true}
            options={credentials.records}
            value={data.permissions[policy]}
            ref="permissions"
          />
        </virtual>

        <div class="hr"></div>

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

    tag.policies = [
      'view', 'edit', 'create', 'delete', 'download_originals', 'tagging',
      'view_meta'
    ];

    tag.on 'before-mount', ->
      tag.errors = {}

    tag.on 'mount', ->
      if tag.opts.id
        fetch()
      else
        tag.data = {}
      fetchCredentials()

    tag.submit = (event) ->
      event.preventDefault()
      p = (if tag.opts.id then update() else create())
      p.then (data) ->
        tag.errors = {}
        window.history.back()
      p.catch (response) ->
        tag.errors = response.data.errors
        wApp.utils.scrollToTop()
      p.finally -> tag.update()

    fetch = ->
      Zepto.ajax(
        url: "/collections/#{tag.opts.id}"
        data: {include: 'permissions'}
        success: (data) ->
          tag.data = data
          tag.update()
      )

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: '/collections'
        data: JSON.stringify(collection: values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/collections/#{tag.opts.id}"
        data: JSON.stringify(collection: values())
      )

    values = ->
      results = {
        name: tag.refs.fields.value()
        permissions: {}
      }
      for f in tag.refs.permissions
        results.permissions[f.name()] ||= f.value()
      results

    fetchCredentials = ->
      Zepto.ajax(
        url: '/credentials',
        success: (data) ->
          tag.credentials = data
          tag.update()
      )

  </script>
</kor-collection-editor>
