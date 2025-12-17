<kor-media-relation>

  <div class="name">
    <a
      if={allowedToUnorder()}
      title={t('order_actions.drop_custom')}
      class="unorder"
      href="#"
      onclick={unorder}
    >
      <i class="fa fa-sort"></i>
    </a>

    {opts.name}

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      on-paginate={pageUpdate}
      class="slim"
    />

    <div class="clearfix"></div>
  </div>

  <virtual if={data}>
    <kor-relationship
      each={relationship in data.records}
      entity={parent.opts.entity}
      relationship={relationship}
      position={data.per_page * (data.page - 1) + i + 1}
    />
  </virtual>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.info);

  // On mount, set up event listeners and fetch data
  tag.on('mount', function() {
    wApp.bus.on('relationship-created', fetch);
    wApp.bus.on('relationship-updated', fetch);
    wApp.bus.on('relationship-deleted', fetch);
    wApp.bus.on('relationship-reorder', fetch);
    tag.opts.query = tag.opts.query || {};
    fetch();
  });

  // On unmount, remove event listeners
  tag.on('unmount', function() {
    wApp.bus.off('relationship-reorder', fetch);
    wApp.bus.off('relationship-deleted', fetch);
    wApp.bus.off('relationship-updated', fetch);
    wApp.bus.off('relationship-created', fetch);
  });

  // Update page and fetch data
  tag.pageUpdate = function(newPage) {
    tag.opts.query.page = newPage;
    fetch();
  };

  // Unorder relationships
  tag.unorder = function(event) {
    event.preventDefault();

    Zepto.ajax({
      type: "DELETE",
      url: "/relationships/unorder",
      data: JSON.stringify({
        from_id: tag.opts.entity.id,
        relation_name: tag.opts.name
      }),
      success: function(data) {
        tag.refresh();
      }
    });
  };

  // Refresh data
  tag.refresh = function() {
    fetch();
  };

  // Fetch relationships data
  var fetch = function() {
    Zepto.ajax({
      url: "/relationships",
      data: {
        from_entity_id: tag.opts.entity.id,
        page: tag.opts.query.page,
        relation_name: tag.opts.name,
        to_kind_id: tag.info().medium_kind_id,
        include: 'all'
      },
      success: function(data) {
        tag.data = data;
        tag.update();
      }
    });
  };

  // Check if unordering is allowed
  tag.allowedToUnorder = function() {
    return tag.allowedTo('edit', tag.opts.entity.collection_id);
  };
</script>

</kor-media-relation>
