<kor-entity-group>
  <div class="kor-content-box">
    <div class="pull-right group-commands">
      <a
        if={opts.type == 'user' || opts.type == 'authority'}
        href="#"
        title={t('add_to_clipboard')}
        onclick={onMarkClicked}
      ><i class="target"></i></a>
      <a
        href="/authority_groups/{opts.id}/download_images"
        title={t('title_verbs.zip')}
      ><i class="zip"></i></a>
    </div>
    <h1>
      {tcap('activerecord.models.' + opts.type + '_group')}
      <span if={group}>"{group.name}"</span>
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
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      fetchGroup()
      tag.on('routing:query', fetch)
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
          wApp.bus.trigger('page-title', data.name);
          fetch();
        }
      })
    }

    var fetch = function() {
      var params = {
        include: 'gallery_data',
        page: tag.opts.query.page
      }

      if (tag.opts.type == 'user') {params['user_group_id'] = tag.opts.id}
      if (tag.opts.type == 'authority') {params['authority_group_id'] = tag.opts.id}

      return Zepto.ajax({
        url: '/entities',
        data: params,
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>
</kor-entity-group>