<kor-menu>

  <ul>
    <li show={!isLoggedIn()}>
      <a href="#/login">{tcap('nouns.login')}</a>
    </li>

    <li show={isLoggedIn()}>
      <a href="#/profile">{tcap('edit_self')}</a>
    </li>

    <li show={isLoggedIn()}>
      <a href="#/clipboard">{tcap('nouns.clipboard')}</a>
    </li>
  </ul>

  <ul show={currentUser()}>
    <li>
      <a href="#/new_media">{tcap('pages.new_media')}</a>
    </li>
    <li>
      <a href="#/search">{tcap('nouns.simple_search')}</a>
    </li>
    <li>
      <a href="#/search">{tcap('nouns.expert_search')}</a>
    </li>
  </ul>

  <ul show={currentUser()}>
    <li>
      <a href="#" onclick={toggleGroups}>
        {tcap('nouns.group', {count: 'other'})}
      </a>

      <ul show={showGroups}>
        <li>
          <a href="#/groups/authority">
            {tcap('activerecord.models.authority_group.other')}
          </a>
        </li>
        <li show={isLoggedIn()}>
          <a href="#/groups/user">
            {tcap('activerecord.models.user_group.other')}
          </a>
        </li>
        <li show={isLoggedIn()}>
          <a href="#/groups/shared">
            {tcap('activerecord.attributes.user_group.shared')}
          </a>
        </li>
        <li show={isLoggedIn()}>
          <a href="#/groups/published">
            {tcap('activerecord.attributes.user_group.shared')}
          </a>
        </li>
      </ul>
    </li>
  </ul>

  <ul show={isLoggedIn() && allowedTo('create')}>
    <li>
      <kor-input
        type="select"
        onchange={newEntity}
        options={kinds}
        placeholder={tcap('objects.new', {interpolations: {o: 'nouns.entity'}})}
        ref="kind_id"
      />
    </li>
    <li show={isLoggedIn()}>
      <a href="#/upload">{tcap('nouns.mass_upload')}</a>
    </li>
  </ul>

  <ul show={isLoggedIn()}>
    <li show={allowedTo('delete')}>
      <a href="#/upload">{tcap('nouns.invalid_entity', {count: 'other'})}</a>
    </li>
    <li show={allowedTo('edit')}>
      <a href="#/upload">{tcap('nouns.new_entity', {count: 'other'})}</a>
    </li>
    <li show={allowedTo('edit')}>
      <a href="#/upload">{tcap('nouns.isolated_entity', {count: 'other'})}</a>
    </li>
  </ul>

  <ul show={hasAnyRole()}>
    <li>
      <a href="#" onclick={toggleConfig}>
        {tcap('nouns.config', {count: 'other'})}
      </a>

      <ul show={showConfig}>
        <li show={hasRole('admin')}>
          <a href="#/config/general">
            {tcap('general')}
          </a>
        </li>
        <li show={hasRole('relation_admin')}>
          <a href="#/relations">
            {tcap('activerecord.models.relation.other')}
          </a>
        </li>
        <li show={hasRole('kind_admin')}>
          <a href="#/kinds">
            {tcap('activerecord.models.kind.other')}
          </a>
        </li>
        <li show={hasRole('admin')}>
          <a href="#/collections">
            {tcap('activerecord.models.collection.other')}
          </a>
        </li>
        <li show={hasRole('admin')}>
          <a href="#/credentials">
            {tcap('activerecord.models.credential.other')}
          </a>
        </li>
        <li show={hasRole('admin')}>
          <a href="#/users">
            {tcap('activerecord.models.user.other')}
          </a>
        </li>
      </ul>
    </li>
  </ul>

  <ul>
    <li>
      <a href="#/stats">{tcap('nouns.statistics')}</a>
    </li>
    <li show={hasRole('admin')}>
      <a href="#/dev">{tcap('activerecord.models.exception_log.other')}</a>
    </li>
  </ul>

  <ul>
    <li>
      <a href="#/legal">{tcap('legal')}</a>
    </li>
    <li>
      <a href="#/about">{tcap('about')}</a>
    </li>
    <li>
      <a href="https://coneda.net" target="_blank">coneda.net</a>
    </li>
  </ul>

  <ul>
    <li show={hasAnyRole()}>
      <a href="https://github.com/coneda/kor/issues">
        {tcap('report_a_problem')}
      </a>
    </li>
    <li hide={hasAnyRole()}>
      <a href="mailto:{config().maintainer.mail}">
        {tcap('report_a_problem')}
      </a>
    </li>
  </ul>


  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.config)

    tag.on 'mount', ->
      $.ajax(
        url: '/kinds'
        success: (data) ->
          tag.kinds = data
          tag.update()
      )

    tag.toggleGroups = (event) ->
      event.preventDefault()
      tag.showGroups = !tag.showGroups
      tag.update()

    tag.toggleConfig = (event) ->
      event.preventDefault()
      tag.showConfig = !tag.showConfig
      tag.update()

    tag.newEntity = (event) ->
      event.preventDefault()
      kind_id = tag.refs.kind_id.value()
      wApp.routing.path "/entities/new?kind_id=#{kind_id}"
      tag.refs.kind_id.set(0)
  </script>

</kor-menu>