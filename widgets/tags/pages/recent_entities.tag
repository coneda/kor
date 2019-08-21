<kor-recent-entities>
  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('nouns.new_entity', {count: 'other'})}</h1>


      <form onchange={submit} onsubmit={submit}>
        <kor-collection-selector
          name="collection_id"
          multiple={true}
          policy="view"
          ref="fields"
        />

        <kor-kind-selector
          name="kind_id"
          include-media={true}
          ref="fields"
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.created_at')}
          name="created_after"
          placeholder={t('from')}
          help={tcap('help.date_input')}
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.created_at')}
          hide-label={true}
          name="created_before"
          placeholder={t('to')}
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.updated_at')}
          name="updated_after"
          placeholder={t('from')}
          help={tcap('help.date_input')}
        />

        <kor-input
          label={tcap('activerecord.attributes.entity.updated_at')}
          hide-label={true}
          name="updated_before"
          placeholder={t('to')}
        />

        <kor-user-selector
          label={tcap('activerecord.attributes.entity.creator')}
          name="created_by"
          ref="fields"
        />

        <kor-user-selector
          label={tcap('activerecord.attributes.entity.updater')}
          name="updated_by"
          ref="fields"
        />
      </form>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <div class="kor-content-box">
      <h1>{tcap('nouns.result', {count: 'other'})}</h1>

      <kor-pagination
        if={data}
        page={opts.query.page}
        per-page={data.per_page}
        total={data.total}
        page-update-handler={pageUpdate}
      />

      <hr />

      <span show={data && data.total == 0}>
        {tcap('objects.none_found', {interpolations: {o: 'activerecord.models.entity.other'}})}
      </span>
      
      <table if={data && data.total > 0}>
        <thead>
          <tr>
            <th>{tcap('activerecord.attributes.entity.name')}</th>
            <th>{tcap('activerecord.attributes.entity.collection_id')}</th>
            <th>
              <kor-sort-by key="created_at">
                {tcap('activerecord.attributes.entity.created_at')}
              </kor-sort-by>
            </th>
            <th>
              <kor-sort-by key="updated_at">
                {tcap('activerecord.attributes.entity.updated_at')}
              </kor-sort-by>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr each={entity in data.records}>
            <td>
              <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a>
              <span class="kind">{entity.kind.name}</span>
            </td>
            <td>{entity.collection.name}</td>
            <td>
              {l(entity.created_at, 'time.formats.exact')}
              <div>{(entity.creator || {}).full_name}</div>
            </td>
            <td>
              {l(entity.updated_at, 'time.formats.exact')}
              <div>{(entity.updater || {}).full_name}</div>
            </td>
          </tr>
        </tbody>
      </table>

      <hr />

      <kor-pagination
        if={data}
        page={opts.query.page}
        per-page={data.per_page}
        total={data.total}
        page-update-handler={pageUpdate}
      />
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.mixin(wApp.mixins.form);

    window.t = tag;

    // tag.on('before-mount', function() {
    //   set();
    // })

    tag.on('mount', function() {
      if (tag.allowedTo('edit')) {
        tag.title(tag.t('pages.recent_entities'));
        tag.setValues(query());
        fetch();
      } else {
        wApp.bus.trigger('access-denied');
      }

      tag.on('routing:query', queryUpdate);
    })

    tag.on('unmount', function() {
      tag.off('routing:query', queryUpdate);
    })

    var queryUpdate = function() {
      tag.setValues(query());
      fetch();
    }

    tag.pageUpdate = function(newPage) {
      wApp.routing.query({page: newPage});
    }

    tag.submit = function(event) {
      wApp.routing.query(formParams());
    }

    var defaultParams = function() {
      return {
        include: 'kind,users,collection,technical',
        per_page: 10,
        date: strftime('%Y-%m-%d'),
        recent: true
      }
    }
      
    var formParams = function() {
      var results = tag.values();
      results['collection_id'] = wApp.utils.arrayToList(results['collection_id']);
      return results;
    }

    var urlParams = function() {
      var results = wApp.routing.query();
      results['collection_id'] = wApp.utils.listToArray(results['collection_id']);
      return results;
    }

    var query = function() {
      return Zepto.extend(defaultParams(), urlParams());
    }

    var fetch = function() {
      // set();

      Zepto.ajax({
        url: '/entities',
        data: query(),
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>
</kor-recent-entities>