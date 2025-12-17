<kor-menu>

  <ul if={currentUser()}>
    <li if={!isLoggedIn()}>
      <a href="#/login">{tcap('nouns.login')}</a>
    </li>
    <li>
      <a href="#/search">{tcap('nouns.search')}</a>
    </li>
  </ul>

  <ul>
    <li if={isLoggedIn() && !isStatic()}>
      <a href="#/clipboard">{tcap('nouns.clipboard')}</a>
    </li>

    <li if={currentUser()}>
      <a href="#/new-media">{tcap(config().new_media_label)}</a>
    </li>
  </ul>

  <div class="header">{tcap('nouns.group', {count: 'other'})}</div>

  <ul>
    <li>
      <a href="#/groups/categories">
        {tcap('activerecord.models.authority_group.other')}
      </a>
    </li>
    <virtual if={!isStatic()}>
      <li if={isLoggedIn()}>
        <a href="#/groups/user">
          {tcap('activerecord.models.user_group.other')}
        </a>
      </li>
      <li if={isLoggedIn()}>
        <a href="#/groups/shared">
          {tcap('activerecord.attributes.user_group.shared', {count: 'other'})}
        </a>
      </li>
      <li if={isLoggedIn()}>
        <a href="#/groups/published">
          {tcap('activerecord.attributes.user_group.published', {count: 'other'})}
        </a>
      </li>
    </virtual>
  </ul>

  <virtual if={isLoggedIn() && (allowedTo('create'))}>
    <div class="header">{tcap('verbs.create')}</div>

    <ul>
      <li>
        <kor-input
          if="{kinds && kinds.records.length > 0}"
          name="new_entity_type"
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
        <a href="#/kinds">
          {tcap('activerecord.models.kind.other')}
        </a>
      </li>
      <li>
        <a href="#/relations">
          {tcap('activerecord.models.relation.other')}
        </a>
      </li>
    </ul>
  </virtual>

  <virtual if={isLoggedIn() && (allowedTo('delete') || allowedTo('edit'))}>
    <div class="header">{tcap('verbs.edit')}</div>

    <ul>
      <li if={allowedTo('edit')}>
        <a href="#/entities/recent">{tcap('nouns.new_entity', {count: 'other'})}</a>
      </li>
      <li if={allowedTo('edit')}>
        <a href="#/entities/isolated">{tcap('nouns.isolated_entity', {count: 'other'})}</a>
      </li>
      <li if={allowedTo('delete')}>
        <a href="#/entities/invalid">{tcap('nouns.invalid_entity', {count: 'other'})}</a>
      </li>
    </ul>
  </virtual>

  <div if={isAdmin()} class="header">{tcap('nouns.administration')}</div>

  <ul if={isAdmin()}>
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
    <li if={hasLegal()}>
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


<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.config);

  // On mount, bind event listeners and fetch kinds
  tag.on('mount', function() {
    wApp.bus.on('reload-kinds', fetchKinds);
    wApp.bus.on('config-updated', tag.update);
    fetchKinds();
  });

  // On unmount, unbind event listeners
  tag.on('umount', function() {
    wApp.bus.off('reload-kinds', fetchKinds);
  });

  // Show help dialog
  tag.showHelp = function(event) {
    event.preventDefault();
    wApp.config.showHelp('general');
  };

  // Check if help is available
  tag.hasHelp = function() {
    return wApp.config.hasHelp('general');
  };

  // Check if legal information is available
  tag.hasLegal = function() {
    return !!wApp.info.data.legal_html;
  };

  // Handle new entity creation
  tag.newEntity = function(event) {
    event.preventDefault();
    var kind_id = tag.refs.kind_id.value();
    wApp.routing.path('/entities/new?kind_id=' + kind_id);
    tag.refs.kind_id.set(0);
  };

  // Fetch kinds from server
  var fetchKinds = function() {
    $.ajax({
      url: '/kinds',
      data: { no_media: true },
      success: function(data) {
        tag.kinds = data;
        tag.update();
      }
    });
  }

</kor-menu>
