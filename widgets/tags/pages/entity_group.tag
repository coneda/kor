<kor-entity-group>

  <div class="kor-content-box">
    <a
      href="/authority_groups/{opts.id}/download_images"
      class="pull-right"
      title={t('title_verbs.zip')}
    ><i class="zip"></i></a>
    <a
      if={opts.type == 'user' || opts.type == 'authority'}
      href="#"
      class="pull-right"
      title={t('add_to_clipboard')}
      onclick={onMarkClicked}
    ><i class="target"></i></a>
    <h1>
      {tcap('activerecord.models.' + opts.type + '_group')}
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

    tag.onMarkClicked = function(event, page) {
      event.preventDefault();

      Zepto.ajax({
        url: '/entities',
        data: {
          user_group_id: tag.opts.id,
          page: page || 1
        },
        success: function(data) {
          console.log(data);
          if (data.total > data.page * data.per_page) {
            tag.onMarkClicked(event, page + 1);
          } else {
            wApp.bus.trigger('message', 'notice', tag.t('objects.marked_entities_success'))
          }

          for (var i = 0; i < data.records.length; i++) {
            wApp.clipboard.add(data.records[i].id);
          }
        }
      })
    }

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