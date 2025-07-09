<kor-kind-editor>

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1 if={opts.id && data}>
        {tcap('objects.edit', {interpolations: {o: data.name}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.kind'}})}
      </h1>

      <virtual if={opts.id}>
        <a href="#/kinds/{opts.id}/edit">
          » {tcap('general', {capitalize: true})}
        </a><br />
      </virtual>

      <hr if={opts.id} />

      <virtual if={data}>
        <kor-fields
          kind={data}
          notify={notify}
        />

        <kor-generators
          kind={data}
          notify={notify}
        />
      </virtual>

      <hr if={opts.id} />

      <div class="kor-text-right">
        <a href="#/kinds" class="kor-button">{t('back_to_list')}</a>
      </div>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <div class="kor-content-box">
      <virtual if={!data}>
        <kor-kind-general-editor />
      </virtual>
      <virtual if={data}>
        <kor-kind-general-editor
          if={!opts.newField && !opts.fieldId && !opts.newGenerator && !opts.generatorId}
          id="{opts.id}"
        />
        <kor-field-editor
          if={opts.newField || opts.fieldId}
          id="{opts.fieldId}"
          kind-id={data.id}
          notify={notify}
        />
        <kor-generator-editor
          if={opts.newGenerator || opts.generatorId}
          id="{opts.generatorId}"
          kind-id={data.id}
          notify={notify}
        />
      </virtual>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this;
  tag.notify = riot.observable();
  // TODO: make sure this works again
  // tag.requireRoles = ['kind_admin']
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.page);

  // Before mounting, check if the user has kind admin privileges
  tag.on('before-mount', function() {
    if (!tag.isKindAdmin()) {
      wApp.bus.trigger('access-denied');
    }
  });

  // On mount, fetch data if an ID is provided
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch();
    }
    tag.notify.on('refresh', fetch);
  });

  // On unmount, remove event listeners
  tag.on('unmount', function() {
    tag.notify.off('refresh', fetch);
  });

  // Fetch kind data
  var fetch = function() {
    Zepto.ajax({
      url: "/kinds/" + tag.opts.id,
      data: { include: 'settings,fields,generators,inheritance' },
      success: function(data) {
        tag.data = data;
        tag.update();
      }
    });
  };
</script>
</kor-kind-editor>