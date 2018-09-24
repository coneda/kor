<kor-entity-group>

  <div class="kor-content-box">
    <h1>
      {tcap('activerecord.models.' + opts.type + '_group')}
      <virtual if={}>{data.name}</virtual>
    </h1>

    <kor-pagination
      if={data}
      page={opts.query.page}
      per-page={data.per_page}
      total={data.total}
      page-update-handler={pageUpdate}
    />

    <div class="hr"></div>

    <span show={data && data.total == 0}>
      {tcap('objects.none_found', {interpolations: {o: 'activerecord.models.entity.other'}})}
    </span>
    
    <kor-gallery-grid if={data} entities={data.records} />

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
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetchGroup()
      tag.on('routing:query', fetch)
      // h(tag.t('pages.new_media')) if h = tag.opts.handlers.pageTitleUpdate
    })

    tag.on('unmount', function() {
      tag.off('routing:query', fetch)
    })

    var fetchGroup = function() {
      return Zepto.ajax({
        url: '/' + tag.opts.type + '_groups/' + tag.opts.id,
        success: function(data) {
          tag.group = data;
          fetch();
        }
      })
    }

    var fetch = function() {
      return Zepto.ajax({
        url: '/entities',
        data: {
          include: 'gallery_data',
          user_group_id: tag.opts.id,
          page: tag.opts.query.page
        },
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

    // tag.pageUpdate = (newPage) -> queryUpdate(page: newPage)

    // queryUpdate = (newQuery) -> h(newQuery) if h = tag.opts.handlers.queryUpdate

  </script>

</kor-entity-group>