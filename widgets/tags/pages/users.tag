<kor-users>

  <div class="kor-content-box">
    <div class="kor-layout-commands">
      <a
        href="#/users/new"
        title={t('verbs.add')}
      ><i class="fa fa-plus-square"></i></a>
    </div>
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
            <a
              onclick={resetLoginAttempts(user.id)}
              title={t('reset_login_attempts')}
            ><i class="fa fa-unlock"></i></a>
            <a
              if={user.name != 'admin' && user.name != 'guest'}
              href="#"
              onclick={resetPassword(user.id)}
              title={t('reset_password')}
            ><i class="fa fa-key"></i></a>
            <a
              href="#/users/{user.id}/edit"
              title={t('verbs.edit')}
            ><i class="fa fa-pencil"></i></a>
            <a
              href="#"
              onclick={destroy(user.id)}
              title={t('verbs.delete')}
            ><i class="fa fa-trash"></i></a>
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

<script type="text/javascript">
  var tag = this
  tag.mixin(wApp.mixins.sessionAware)
  tag.mixin(wApp.mixins.i18n)
  tag.mixin(wApp.mixins.auth)
  tag.mixin(wApp.mixins.page)

  // Before mounting, check admin permission
  tag.on('before-mount', function() {
    if (!tag.isAdmin()) {
      wApp.bus.trigger('access-denied')
    }
  })

  // On mount, set title and fetch data, bind routing event
  tag.on('mount', function() {
    tag.title(tag.t('activerecord.models.user', {count: 'other'}))
    fetch()
    tag.on('routing:query', fetch)
  })

  // On unmount, unbind routing event
  tag.on('unmount', function() {
    tag.off('routing:query', fetch)
  })

  // Fetch user data from server
  var fetch = function(newOpts) {
    Zepto.ajax({
      url: '/users',
      data: {
        include: 'security,technical',
        terms: tag.opts.query.search,
        page: tag.opts.query.page
      },
      success: function(data) {
        tag.data = data
        tag.update()
      }
    })
  }

  // Reset login attempts for a user
  tag.resetLoginAttempts = function(id) {
    return function(event) {
      event.preventDefault()
      Zepto.ajax({
        type: 'PATCH',
        url: '/users/' + id + '/reset_login_attempts'
      })
    }
  }

  // Reset password for a user
  tag.resetPassword = function(id) {
    return function(event) {
      event.preventDefault()
      if (confirm(tag.t('confirm.sure'))) {
        Zepto.ajax({
          type: 'PATCH',
          url: '/users/' + id + '/reset_password'
        })
      }
    }
  }

  // Delete a user
  tag.destroy = function(id) {
    return function(event) {
      event.preventDefault()
      if (confirm(tag.t('confirm.sure'))) {
        Zepto.ajax({
          type: 'DELETE',
          url: '/users/' + id,
          success: function() {
            fetch()
          }
        })
      }
    }
  }

  // Handle page change (pagination)
  tag.pageUpdate = function(newPage) {
    queryUpdate({ page: newPage })
  }

  // Handle search form submit
  tag.search = function(event) {
    event.preventDefault()
    queryUpdate({
      page: 1,
      search: tag.refs.search.value()
    })
  }

  // Trigger query update event
  var queryUpdate = function(newQuery) {
    wApp.bus.trigger('query-update', newQuery)
  }

</kor-users>
