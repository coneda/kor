<kor-clipboard>
  
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <div class="kor-layout-commands">
        <a onclick={reset}><i class="minus"></i></a>
      </div>
      <h1>{tcap('nouns.clipboard')}</h1>

      <div class="mass-subselect">
        <a href="#" onclick={selectAll}>{t('all')}</a> |
        <a href="#" onclick={selectNone}>{t('none')}</a>
      </div>

      <kor-pagination
        if={data}
        page={data.page}
        per-page={data.per_page}
        total={data.total}
        on-paginate={page}
        per-page-control={true}
      />

      <hr />

      <span show={data && data.total == 0}>
        {tcap('objects.none_found', {interpolations: {o: 'nouns.entity.one'}})}
      </span>

      <kor-nothing-found data={data} />

      <table if={data}>
        <tbody>
          <tr each={entity in data.records}>
            <td>
              <kor-clipboard-subselect-control entity={entity}/>
            </td>
            <td>
              <a href="#/entities/{entity.id}">
                <span show={!entity.medium}>{entity.display_name}</span>
                <img
                  if={entity.medium}
                  src={entity.medium.url.icon}
                  class="image"
                />
              </a>
            </td>
            <td class="right nobreak">
              <a onclick={remove(entity.id)}><i class="minus"></i></a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-small">
    <div class="kor-content-box">
      <kor-mass-action
        if={data}
        ids={selectedIds()}
        on-action-success={reload}
      />
    </div>
  </div>

  <div class="clearfix"></div>
  
  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);

    tag.on('mount', function() {
      wApp.bus.on('routing:query', fetch);

      if (tag.currentUser() && !tag.isGuest()) {
        fetch()
      } else {
        if (h = tag.opts.handlers.accessDenied) {
          h()
        }
      }
    })

    tag.on('umount', function() {
      wApp.bus.off('routing:query', fetch);
    });

    tag.reload = function() {
      fetch();
    }

    tag.selectAll = function(event) {
      event.preventDefault();
      wApp.clipboard.subSelectAll();
    }

    tag.selectNone = function(event) {
      event.preventDefault();
      wApp.clipboard.resetSubSelection();
    }

    tag.selectedIds = function() {
      return wApp.clipboard.subSelection();
    }

    tag.reset = function(event) {
      event.preventDefault();
      wApp.clipboard.reset();
      fetch();
    }
      
    tag.remove = function(id) {
      return function(event) {
        event.preventDefault();
        wApp.clipboard.remove(id);
        fetch();
      }
    }

    tag.page = function(newPage, newPerPage) {
      wApp.routing.query({
        page: newPage,
        per_page: newPerPage
      });
    }

    var urlParams = function() {
      var results = wApp.routing.query();
      results['id'] = wApp.clipboard.ids().join(',');
      return results;
    }

    var fetch = function() {
      var params = urlParams();

      if (params['id'].length) {
        Zepto.ajax({
          url: '/entities',
          data: urlParams(),
          success: function(data) {
            tag.data = data;
            tag.update();
          }
        })
      } else {
        tag.data = null;
        tag.update();
      }
    }
  </script>

</kor-clipboard>