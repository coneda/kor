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
          onchange={selectKind}
        />

        <kor-input
          if={elastic()}
          name="terms"
          label={tcap('nouns.term', {count: 'other'})}
          value={criteria.terms}
          ref="fields"
          help={tcap('help.terms_query')}
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

        <virtual if={elastic()}>
          <virtual if={kind && kind.fields.length}>
            <hr />

            <kor-input
              each={field in kind.fields}
              label={field.search_label}
              name="dataset_{field.name}"
              value={criteria['dataset_' + field.name]}
              ref="fields"
            />
          </virtual>

          <hr />

          <kor-input
            name="property"
            label={tcap('activerecord.attributes.entity.properties')}
            value={criteria.property}
            ref="fields"
          />

          <kor-input
            name="related"
            label={tcap('by_related_entities')}
            value={criteria.related}
            ref="fields"
          />
        </virtual>

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
    tag.mixin(wApp.mixins.page);

    tag.on('before-mount', function() {
      tag.criteria = urlParams();
    })

    tag.on('mount', function() {
      tag.title(tag.t('nouns.search'))
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

    tag.selectKind = function(event) {
      var id = Zepto(event.target).val();
      if (id && id != '0') {
        fetchKind(id);
      } else {
        tag.kind = null;
        tag.update();
      }
    }

    tag.elastic = function() {
      return wApp.info.data.elastic
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

    var fetchKind = function(id) {
      Zepto.ajax({
        url: '/kinds/' + id,
        data: {include: 'fields'},
        success: function(data) {
          tag.kind = data;
          tag.update();
        }
      })
    }

    var fetch = function() {
      tag.criteria = urlParams();
      if (tag.criteria['kind_id']) {
        fetchKind(2);
      }

      var params = Zepto.extend({}, tag.criteria, {
        except_kind_id: wApp.info.data.medium_kind_id,
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