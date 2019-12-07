<kor-profile>
  <kor-help-button key="profile" />

  <div class="kor-layout-left kor-layout-large" show={loaded}>
    <div class="kor-content-box">
      <h1>{tcap('objects.edit', {interpolations: {o: 'nouns.profile'}})}</h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.user.full_name')}
          name="full_name"
          ref="fields"
          value={data.full_name}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.email')}
          name="email"
          ref="fields"
          value={data.email}
          errors={errors.email}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.plain_password')}
          name="plain_password"
          type="password"
          ref="fields"
          errors={errors.plain_password}
        />

        <kor-input
          label={tcap('activerecord.attributes.user.plain_password_confirmation')}
          name="plain_password_confirmation"
          type="password"
          ref="fields"
          errors={errors.plain_password_confirmation}
        />

        <hr />

        <kor-input
          label={tcap('activerecord.attributes.user.api_key')}
          name="api_key"
          type="textarea"
          ref="fields"
          value={data.api_key}
          errors={errors.api_key}
        />

        <hr />

        <kor-input
          label={tcap('activerecord.attributes.user.locale')}
          name="locale"
          type="select"
          options={['de', 'en']}
          ref="fields"
          value={data.locale}
        />

        <hr />

        <kor-input
          if={collections}
          label={tcap('activerecord.attributes.user.default_collection_id')}
          name="default_collection_id"
          type="select"
          options={collections.records}
          ref="fields"
          value={data.default_collection_id}
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
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.page)

    tag.on 'mount', ->
      tag.title(tag.t('objects.edit', {interpolations: {o: 'nouns.profile'}}))
      tag.errors = {}

      if tag.currentUser() && !tag.isGuest()
        Zepto.when(fetchCollections(), fetchUser()).then ->
          tag.loaded = true
          tag.update()
      else
        wApp.bus.trigger('access-denied')

    tag.submit = (event) ->
      event.preventDefault()
      p = update()
      p.done (data) ->
        tag.errors = {}
        window.history.back()
        wApp.bus.trigger 'reload-session'
        # riot.update() # so locale changes take effect
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
        wApp.utils.scrollToTop()
      p.always -> tag.update()
      
    tag.expiresIn = (days) ->
      (event) ->
        if days
          date = new Date()
          date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000)
          expiresAtTag().set(strftime '%Y-%m-%d', date)
        else
          expiresAtTag().set undefined

    tag.valueForDate = (date) ->
      if date then strftime('%Y-%m-%d', new Date(date)) else ''

    fetchUser = ->
      Zepto.ajax(
        url: "/users/me"
        data: {include: 'security'}
        success: (data) ->
          tag.data = data
          tag.update()
      )

    fetchCollections = ->
      Zepto.ajax(
        url: '/collections'
        success: (data) ->
          tag.collections = data
          tag.update()
      )

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/users/me"
        data: JSON.stringify(
          id: tag.currentUser().id
          user: values()
        )
      )

    expiresAtTag = ->
      for f in tag.refs.fields
        return f if f.name() == 'expires_at'
      undefined

    values = ->
      results = {}
      for f in tag.refs.fields
        results[f.name()] = f.value()
      results

  </script>

</kor-profile>