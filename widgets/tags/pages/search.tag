<kor-search>
  <kor-help-button key="search" />

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('nouns.search')}</h1>

      <form onsubmit={submit}>
        <kor-collection-selector
          name="collection_id"
          multiple={true}
          policy="view"
          ref="fields"
        />

        <kor-kind-selector
          name="kind_id"
          onchange={selectKind}
          ref="fields"
        />

        <kor-input
          if={elastic()}
          name="terms"
          label={tcap('nouns.term', {count: 'other'})}
          help={tcap('help.terms_query')}
        />

        <kor-input
          name="name"
          label={tcap('activerecord.attributes.entity.name')}
        />

        <kor-input
          name="tags"
          label={tcap('nouns.tag', {count: 'other'})}
        />

        <kor-input
          name="dating"
          label={tcap('activerecord.models.entity_dating')}
        />

        <virtual if={elastic()}>
          <virtual if={kind && kind.fields.length}>
            <hr />

            <kor-input
              each={field in kind.fields}
              label={field.search_label}
              name="dataset_{field.name}"
              ref="fields"
            />
          </virtual>

          <hr />

          <kor-input
            name="property"
            label={tcap('activerecord.attributes.entity.properties')}
          />

          <kor-input
            name="related"
            label={tcap('by_related_entities')}
          />
        </virtual>

        <div class="kor-text-right">
          <kor-input
            type="submit"
            riot-value={tcap('verbs.search')}
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
      />

      <kor-search-result
        each={entity in data.records}
        entity={entity}
      />

      <kor-pagination
        page={data.page}
        per-page={data.per_page}
        total={data.total}
        on-paginate={page}
      />
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.mixin(wApp.mixins.form);

    tag.on('mount', function() {
      tag.title(tag.t('nouns.search'));

      queryUpdate();
      tag.on('routing:query', queryUpdate);
    })

    tag.on('unmount', function() {
      tag.off('routing:query', queryUpdate);
    })

    var queryUpdate = function() {
      tag.setValues(urlParams());
      fetch();
    }

    tag.submit = function(event) {
      event.preventDefault();
      wApp.routing.query(formParams(), true);
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
      return wApp.info.data.elastic
    }

    var defaultParams = function() {
      return {
        except_kind_id: wApp.info.data.medium_kind_id,
        per_page: 10,
        include: 'related',
        related_kind_id: wApp.info.data.medium_kind_id,
        related_per_page: 4
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

    var fetchKind = function(id) {
      Zepto.ajax({
        url: '/kinds/' + id,
        data: {include: 'fields'},
        success: function(data) {
          tag.kind = data;
          tag.update();
          tag.setValues(urlParams());
        }
      })
    }

    var fetch = function() {
      var kind_id = urlParams()['kind_id'];
      if (kind_id) {
        fetchKind(kind_id);
      }

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

</kor-search>