<kor-user-group-editor>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.user_group'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.user_group'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.user_group.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

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

    tag.on 'before-mount', ->
      tag.errors = {}
      tag.data = {}

    tag.on 'mount', ->
      fetch() if tag.opts.id

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
        url: "/user_groups/#{tag.opts.id}"
        success: (data) ->
          tag.data = data
          tag.update()
      )

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: '/user_groups'
        data: JSON.stringify(user_group: values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/user_groups/#{tag.opts.id}"
        data: JSON.stringify(user_group: values())
      )

    values = ->
      {name: tag.refs.fields.value()}

  </script>

</kor-user-group-editor>
