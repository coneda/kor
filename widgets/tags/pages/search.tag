<kor-search>
  <kor-help-button key="search" />

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('nouns.search')}</h1>

      <form onsubmit={submit}>
        <kor-collection-selector
          name="collection_id"
          multiple={true}
          value={criteria.collection_id}
          policy="view"
          ref="fields"
        />

        <kor-kind-selector
          name="kind_id"
          value={criteria.kind_id}
          ref="fields"
        />

        <kor-input
          name="terms"
          label={tcap('nouns.term', {count: 'other'})}
          value={criteria.terms}
          ref="fields"
        />

        <kor-input
          name="name"
          label={tcap('activerecord.attributes.entity.name')}
          value={criteria.name}
          ref="fields"
        />

        <kor-input
          name="tags"
          label={tcap('nouns.tag', {count: 'other'})}
          value={criteria.tags}
          ref="fields"
        />

        <kor-input
          name="dating"
          label={tcap('activerecord.models.entity_dating')}
          value={criteria.dating}
          ref="fields"
        />

        <div class="kor-text-right">
          <kor-input type="submit" value={tcap('verbs.search')} />
        </div>
      </form>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <div class="kor-content-box">
      <h1>{tcap('nouns.search_results')}</h1>
    </div>

    <kor-nothing-found data={data} type="entity" />

    <div class="search-results" if={data && data.total > 0}>
      <kor-pagination
        page={data.page}
        per-page={data.per_page}
        total={data.total}
        on-paginate={page}
      />

      <kor-search-result
        each={entity in data.records}
        entity={entity}
      />
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('before-mount', function() {
      tag.criteria = urlParams();
    })

    tag.on('mount', function() {
      fetch()
      tag.on('routing:query', fetch)
    })

    tag.on('unmount', function() {
      tag.off('routing:query', fetch)
    })

    tag.submit = function(event) {
      event.preventDefault();
      wApp.routing.query(params(), true);
    }

    tag.page = function(newPage) {
      wApp.routing.query({page: newPage});
    }

    var params = function() {
      var results = {page: 1};
      for (var i = 0; i < tag.refs.fields.length; i++) {
        var f = tag.refs.fields[i];
        var v = f.value();
        if (v != '' && v != [] && v != undefined) {
          if (Zepto.isArray(v)) {
            results[f.name()] = v.join(',');
          } else {
            results[f.name()] = v;
          }
        }
      }
      return results;
    }

    var urlParams = function() {
      var results = wApp.routing.query();
      results['collection_id'] = wApp.utils.toIdArray(results['collection_id']);
      return results;
    } 

    var fetch = function() {
      tag.criteria = urlParams();

      var params = Zepto.extend({}, tag.criteria, {
        no_media: true,
        include: 'related',
        related_kind_id: wApp.info.data.medium_kind_id,
        related_per_page: 4
      });

      Zepto.ajax({
        url: '/entities',
        data: params,
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

  </script>

</kor-search>