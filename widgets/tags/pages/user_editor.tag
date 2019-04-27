<kor-user-editor>
  <div class="kor-layout-left kor-layout-large" show={loaded}>
    <div class="kor-content-box">
      <h1 show={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.user'}})}
      </h1>
      <h1 show={!opts.id}>
        {tcap('objects.new', {interpolations: {o: 'activerecord.models.user'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          name="lock_version"
          type="hidden"
        />

        <kor-input
          label={tcap('activerecord.attributes.user.personal')}
          name="make_personal"
          type="checkbox"
          errors={errors.make_personal}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.full_name')}
          name="full_name"
        />

        <kor-input
          label={tcap('activerecord.attributes.user.name')}
          name="name"
          errors={errors.name}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.email')}
          name="email"
          errors={errors.email}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.api_key')}
          name="api_key"
          type="textarea"
          errors={errors.api_key}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.active')}
          name="active"
          type="checkbox"
        />

        <div class="expires-at">
          <kor-input
            label={tcap('activerecord.attributes.user.expires_at')}
            name="expires_at"
            type="date"
            errors={errors.expires_at}
            ref="expires-at"
          />

          <button onclick={expiresIn(0)}>
            {tcap('activerecord.attributes.user.does_not_expire')}
          </button>
          <button onclick={expiresIn(7)}>
            {tcap('activerecord.attributes.user.expires_in_days', {interpolations: {amount: 7}})}
          </button>
          <button onclick={expiresIn(30)}>
            {tcap('activerecord.attributes.user.expires_in_days', {interpolations: {amount: 30}})}
          </button>
          <button onclick={expiresIn(180)}>
            {tcap('activerecord.attributes.user.expires_in_days', {interpolations: {amount: 180}})}
          </button>

          <div class="clearfix"></div>
        </div>

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.parent_username')}
          name="parent_username"
          type="text"
          errors={errors.parent_username}
        />

        <div class="hr"></div>

        <kor-input
          if={credentials}
          label={tcap('activerecord.attributes.user.groups')}
          name="group_ids"
          type="select"
          options={credentials.records}
          multiple={true}
        />

        <div class="hr"></div>

        <kor-input
          label={tcap('activerecord.attributes.user.authority_group_admin')}
          name="authority_group_admin"
          type="checkbox"
        />

        <kor-input
          label={tcap('activerecord.attributes.user.relation_admin')}
          name="relation_admin"
          type="checkbox"
        />

        <kor-input
          label={tcap('activerecord.attributes.user.kind_admin')}
          name="kind_admin"
          type="checkbox"
        />

        <kor-input
          label={tcap('activerecord.attributes.user.admin')}
          name="admin"
          type="checkbox"
        />

        <div class="hr"></div>

        <kor-input
          type="submit"
          value={tcap('verbs.save')}
        />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.page)
    tag.mixin(wApp.mixins.form)

    window.t = this

    tag.on 'mount', ->
      tag.errors = {}

      if tag.isAdmin()
        Zepto.when(fetchCredentials(), fetchUser()).then ->
          tag.loaded = true
          tag.update()
      else
        wApp.bus.trigger('access-denied')

    tag.submit = (event) ->
      event.preventDefault()
      p = if tag.opts.id then update() else create()
      p.done (data) -> wApp.bus.trigger('go-back')
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()

    # TODO: this needs to be done entirely on the server. The client should
    # just tranfer the amount of days to add      
    tag.expiresIn = (days) ->
      (event) ->
        event.preventDefault()

        if days
          date = new Date()
          date = new Date(date.getTime() + days * 24 * 60 * 60 * 1000)
          tag.refs['expires-at'].set([
            date.getUTCFullYear(),
            ('00' + (date.getUTCMonth() + 1)).substr(-2, 2),
            ('00' + date.getUTCDate()).substr(-2, 2)
          ].join('-'))
        else
          tag.refs['expires-at'].set undefined

    tag.valueForDate = (date) ->
      if date then strftime('%Y-%m-%d', new Date(date)) else ''

    fetchCredentials = ->
      Zepto.ajax(
        url: '/credentials'
        success: (data) ->
          tag.credentials = data
          tag.update()
      )

    tag.oldSetValues = tag.setValues
    tag.setValues = (values) ->
      values.expires_at = tag.valueForDate(values.expires_at)
      tag.oldSetValues(values)

    fetchUser = ->
      if tag.opts.id
        Zepto.ajax(
          url: "/users/#{tag.opts.id}"
          data: {include: 'all'}
          success: (data) ->
            tag.data = data
            tag.update()
            tag.setValues(tag.data)
        )
      else
        tag.data = {
          lock_version: 0
        }
        tag.setValues(tag.data)
        tag.update()

    create = ->
      Zepto.ajax(
        type: 'POST'
        url: "/users"
        data: JSON.stringify(user: tag.values())
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/users/#{tag.opts.id}"
        data: JSON.stringify(user: tag.values())
      )
  </script>
</kor-user-editor>