<kor-users>

  <div class="kor-content-box">
    <h1>{tcap('activerecord.models.user', {count: 'other'})}</h1>

    <form onsubmit={search} class="inline">
      <kor-input
        label={t('nouns.search')}
        ref="search"
        value={opts.query.search}
      />
    </form>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />

    <div class="hr"></div>

    <span show={data && data.total == 0}>
      {tcap('objects.none_found', {interpolations: {o: 'nouns.entity.one'}})}
    </span>

    <table if={data}>
      <thead>
        <tr>
          <th class="tiny">{t('activerecord.attributes.user.personal')}</th>
          <th class="small">{t('activerecord.attributes.user.name')}</th>
          <th class="small">{t('activerecord.attributes.user.full_name')}</th>
          <th>{t('activerecord.attributes.user.email')}</th>
          <th class="tiny right">
            {t('activerecord.attributes.user.created_at')}
          </th>
          <th class="tiny right">
            {t('activerecord.attributes.user.last_login')}
          </th>
          <th class="tiny right">
            {t('activerecord.attributes.user.expires_at')}
          </th>
          <th class="tiny buttons"></th>
        </tr>
      </thead>
      <tbody>
        <tr each={user in data.records}>
          <td><i show={user.personal} class="fa fa-check"></i></td>
          <td>{user.name}</td>
          <td>{user.full_name}</td>
          <td class="force-wrap">
            <a href="mailto:{user.email}">{user.email}</a>
          </td>
          <td class="right">{l(user.created_at)}</td>
          <td class="right">{l(user.last_login)}</td>
          <td class="right">{l(user.expires_at)}</td>
          <td class="right nobreak">
            <a onclick={resetLoginAttempts(user.id)}>
              <i class="three_bars"></i>
            </a>
            <a onclick={resetPassword(user.id)}>
              <i class="reset_password"></i>
            </a>
            <a href="#/users/{user.id}/edit"><i class="pen"></i></a>
            <a onclick={destroy(user.id)}><i class="x"></i></a>
          </td>
        </tr>
      </tbody>
    </table>

    <div class="hr"></div>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', ->
      if tag.hasRole('admin')
        fetch()
        tag.on 'routing:query', fetch
      else
        h() if h = tag.opts.handlers.accessDenied

    fetch = (newOpts) ->
      Zepto.ajax(
        url: '/users'
        data: {
          include: 'security,technical'
          search_string: tag.opts.query.search
          page: tag.opts.query.page
        }
        success: (data) ->
          tag.data = data
          tag.update()
      )

    tag.resetLoginAttempts = (id) ->
      (event) ->
        event.preventDefault()
        Zepto.ajax(
          type: 'PATCH'
          url: "/users/#{id}/reset_login_attempts"
        )

    tag.resetPassword = (id) ->
      (event) ->
        event.preventDefault()
        if confirm(tag.t('confirm.sure'))
          Zepto.ajax(
            type: 'PATCH'
            url: "/users/#{id}/reset_password"
          )

    tag.destroy = (id) ->
      (event) ->
        event.preventDefault()
        if confirm(tag.t('confirm.sure'))
          Zepto.ajax(
            type: 'DELETE'
            url: "/users/#{id}"
            success: -> fetch()
          )

    tag.pageUpdate = (newPage) -> queryUpdate(page: newPage)
    tag.search = (event) ->
      event.preventDefault()
      queryUpdate(
        page: 1
        search: tag.refs.search.value()
      )

    queryUpdate = (newQuery) -> h(newQuery) if h = tag.opts.handlers.queryUpdate
  </script>

</kor-users>