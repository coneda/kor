<kor-menu>

  <ul>
    <li if={!isLoggedIn()}>
      <a href="#/login">{tcap('nouns.login')}</a>
    </li>

    <li if={isLoggedIn()}>
      <a href="#/profile">{tcap('edit_self')}</a>
    </li>

    <li if={isLoggedIn()}>
      <a href="#/clipboard">{tcap('nouns.clipboard')}</a>
    </li>
  </ul>

  <ul if={currentUser()}>
    <li>
      <a href="#/new-media">{tcap('pages.new_media')}</a>
    </li>
    <li>
      <a href="#/search">{tcap('nouns.search')}</a>
    </li>
  </ul>

  <ul>
    <li>
      <a href="#/groups/categories">
        {tcap('activerecord.models.authority_group.other')}
      </a>
    </li>
    <li if={isLoggedIn()}>
      <a href="#/groups/user">
        {tcap('activerecord.models.user_group.other')}
      </a>
    </li>
    <li if={isLoggedIn()}>
      <a href="#/groups/shared">
        {tcap('activerecord.attributes.user_group.shared')}
      </a>
    </li>
    <li if={isLoggedIn()}>
      <a href="#/groups/published">
        {tcap('activerecord.attributes.user_group.published')}
      </a>
    </li>
  </ul>

  <ul if={isLoggedIn() && allowedTo('create')}>
    <li>
      <kor-input
        if="{kinds && kinds.records.length > 0}"
        type="select"
        onchange={newEntity}
        options={kinds.records}
        placeholder={tcap('objects.new', {interpolations: {o: 'activerecord.models.entity.one'}})}
        ref="kind_id"
      />
    </li>
    <li if={isLoggedIn()}>
      <a href="#/upload">{tcap('verbs.upload')}</a>
    </li>
    <li>
      <a href="#/relations">
        {tcap('activerecord.models.relation.other')}
      </a>
    </li>
    <li>
      <a href="#/kinds">
        {tcap('activerecord.models.kind.other')}
      </a>
    </li>
  </ul>

  <ul if={isLoggedIn()}>
    <li if={allowedTo('delete')}>
      <a href="#/entities/invalid">{tcap('nouns.invalid_entity', {count: 'other'})}</a>
    </li>
    <li if={allowedTo('edit')}>
      <a href="#/entities/recent">{tcap('nouns.new_entity', {count: 'other'})}</a>
    </li>
    <li if={allowedTo('edit')}>
      <a href="#/entities/isolated">{tcap('nouns.isolated_entity', {count: 'other'})}</a>
    </li>
  </ul>

  <virtual if={isAdmin()}>
  <ul>
    <li>
      {tcap('nouns.administration')}
    </li>
    <li>
      <a href="#/settings">
        {tcap('activerecord.models.setting', {count: 'other'})}
      </a>
    </li>
    <li>
      <a href="#/collections">
        {tcap('activerecord.models.collection.other')}
      </a>
    </li>
    <li>
      <a href="#/credentials">
        {tcap('activerecord.models.credential.other')}
      </a>
    </li>
    <li>
      <a href="#/users">
        {tcap('activerecord.models.user.other')}
      </a>
    </li>
  </ul>

  <ul>
    <li if={hasHelp()}>
      <a href="#/help" onclick={showHelp}>{tcap('nouns.help')}</a>
    </li>
    <li>
      <a href="#/statistics">{tcap('nouns.statistics')}</a>
    </li>
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
    <li if={hasAnyRole()}>
      <a href="https://github.com/coneda/kor/issues">
        {tcap('report_a_problem')}
      </a>
    </li>
    <li hide={hasAnyRole()}>
      <a href="mailto:{config().maintainer_mail}">
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
      wApp.bus.on 'reload-kinds', fetchKinds
      fetchKinds()

    tag.on 'umount', ->
      wApp.bus.off 'reload-kinds', fetchKinds

    # tag.toggleGroups = (event) ->
    #   event.preventDefault()
    #   tag.showGroups = !tag.showGroups
    #   tag.update()

    # tag.toggleConfig = (event) ->
    #   # TODO: memorize this with local storage (Lockr)
    #   event.preventDefault()
    #   tag.showConfig = !tag.showConfig
    #   tag.update()

    tag.showHelp = (event) ->
      event.preventDefault()
      wApp.config.showHelp('general')

    tag.hasHelp = -> return wApp.config.hasHelp('general');

    tag.newEntity = (event) ->
      event.preventDefault()
      kind_id = tag.refs.kind_id.value()
      wApp.routing.path "/entities/new?kind_id=#{kind_id}"
      tag.refs.kind_id.set(0)

    fetchKinds = ->
      $.ajax(
        url: '/kinds'
        data: {no_media: true}
        success: (data) ->
          tag.kinds = data
          tag.update()
      )

  </script>

</kor-menu>