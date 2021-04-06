<kor-search>
  <kor-help-button key="search" />

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('nouns.search')}</h1>

      <form onsubmit={submit}>
        <kor-collection-selector
          show={allowedTo('create')}
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
          include-media={true}
        />

        <kor-input
          if={elastic()}
          name="terms"
          label={tcap('all_fields')}
          value={criteria.terms}
          ref="fields"
          help={tcap('help.terms_query')}
        />

        <kor-input
          name="name"
          label={config()['search_entity_name']}
          value={criteria.name}
          ref="fields"
          help={tcap('help.name_query')}
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
          help={tcap('help.dating_query')}
        />

        <virtual if={isMedia(kind)}>
          <div class="hr"></div>

          <kor-input
            name="file_name"
            label={tcap('activerecord.attributes.medium.file_name')}
            value={criteria.file_name}
            ref="fields"
          />

          <kor-input
            if={mime_types}
            name="file_type"
            label={tcap('activerecord.attributes.medium.file_type')}
            type="select"
            options={mime_types}
            placeholder={t('all')}
            value={criteria.file_type}
            ref="fields"
          />

          <kor-input
            name="file_size"
            label={tcap('activerecord.attributes.medium.file_size')}
            value={criteria.file_size}
            ref="fields"
            help={tcap('help.file_size_query')}
          />

          <kor-input
            name="datahash"
            label={tcap('activerecord.attributes.medium.datahash')}
            value={criteria.datahash}
            ref="fields"
          />
        </virtual>

        <virtual if={elastic()}>
          <virtual if={kind && kind.fields.length}>
            <div class="hr"></div>

            <kor-input
              each={field in kind.fields}
              label={field.search_label}
              name="dataset_{field.name}"
              value={criteria['dataset_' + field.name]}
              ref="fields"
            />
          </virtual>

          <div class="hr"></div>

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
          <kor-input
            type="submit"
            label={tcap('verbs.search')}
          />
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
        class="top"
      />

      <div class="kor-search-results">
        <kor-search-result
          each={entity in data.records}
          entity={entity}
        />
      </div>

      <kor-pagination
        page={data.page}
        per-page={data.per_page}
        total={data.total}
        on-paginate={page}
        class="bottom"
      />
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.page);

    tag.on('before-mount', function() {
      fetchMimeTypes();
      tag.criteria = urlParams();
    })

    tag.on('mount', function() {
      tag.title(tag.t('nouns.search'));
      tag.on('routing:query', queryUpdate);
      queryUpdate();
    })

    tag.on('unmount', function() {
      tag.off('routing:query', queryUpdate)
    })

    var queryUpdate = function() {
      tag.criteria = urlParams();
      tag.update();
      
      if (tag.criteria['kind_id']) {
        fetchKind(tag.criteria['kind_id']);
      }
      tag.tags['kor-collection-selector'].reset();
      fetch();
    }

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
        wApp.routing.query({kind_id: id});
      } else {
        tag.kind = null;
        tag.update();
      }
    }

    tag.elastic = function() {
      return wApp.info.data.elastic;
    }

    tag.isMedia = function(kind) {
      if (!kind) {return false;}

      return kind.id === wApp.info.data.medium_kind_id;
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

    var fetchMimeTypes = function() {
      Zepto.ajax({
        url: '/statistics',
        success: function(data) {
          tag.mime_types = Object.keys(data.mime_counts).sort();
          tag.update();
        }
      })
    }

    var fetch = function() {
      var params = Zepto.extend({}, tag.criteria, {
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