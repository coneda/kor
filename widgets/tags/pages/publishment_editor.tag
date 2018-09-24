<kor-publishment-editor>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.publishment'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.publishment'}})}
      </h1>

      <form onsubmit={submit}>
        <kor-input
          label={tcap('activerecord.attributes.publishment.name')}
          name="name"
          ref="fields"
          errors={errors.name}
          autofocus={true}
        />

        <kor-input
          if={userGroups}
          label={tcap('activerecord.models.user_group')}
          name="user_group_id"
          type="select"
          options={userGroups}
          ref="fields"
          errors={errors.user_group}
        />

        <kor-input type="submit" value={tcap('verbs.save')} />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'before-mount', ->
      fetchGroups()
      tag.data = {}
      tag.errors = {}

    tag.submit = (event) ->
      event.preventDefault()
      p = create()
      p.done (data) ->
        tag.errors = {}
        id = tag.opts.id || data.id
        wApp.routing.path('/groups/published')
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: '/publishments'
        data: JSON.stringify(publishment: values())
      )

    values = ->
      results = {}
      for f in tag.refs.fields
        console.log f
        results[f.name()] = f.value()
      results

    fetchGroups = ->
      Zepto.ajax(
        url: '/user_groups'
        success: (data) ->
          tag.userGroups = []
          for record in data.records
            tag.userGroups.push(value: record.id, label: record.name)
          tag.update()
      )
  </script>

</kor-publishment-editor>