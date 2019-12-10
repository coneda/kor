<kor-entity-merger>
  <div class="kor-content-box">
    <h1>{tcap('verbs.merge')}</h1>

    <div if={error} class="error">{tcap(error)}</div>

    <form if={data} onsubmit={submit}>
      <kor-input
        name="uuid"
        label={tcap('activerecord.attributes.entity.uuid')}
        type="select"
        options={combined.uuid}
        ref="fields"
      />

      <kor-input
        name="subtype"
        label={tcap('activerecord.attributes.entity.subtype')}
        type="select"
        options={combined.subtype}
        ref="fields"
      />

      <kor-collection-selector
        label={tcap('activerecord.attributes.entity.collection_id')}
      />

      <kor-input
        label={tcap('activerecord.attributes.entity.name')}
        name="no_name_statement"
        type="radio"
        ref="fields"
        options={noNameStatements}
      />

      <kor-input
        name="name"
        label={tcap('activerecord.attributes.entity.name')}
        type="select"
        options={combined.name}
        ref="fields"
      />

      <kor-input
        name="distinct_name"
        label={tcap('activerecord.attributes.entity.distinct_name')}
        type="select"
        options={combined.distinct_name}
        ref="fields"
      />

      <kor-input
        if="combined.medium_id.length > 0"
        label={tcap('activerecord.models.medium')}
        name="medium_id"
        type="radio"
        options={media}
        value={combined.medium_id[0]}
        ref="fields"
      />

      <kor-input
        if="{combined.comment.length > 0}"
        name="comment"
        label={tcap('activerecord.attributes.entity.comment')}
        type="radio"
        options={combined.comment}
        ref="fields"
      />

      <kor-input
        name="tag_list"
        label={tcap('activerecord.attributes.entity.tag_list')}
        value={combined.tags.join(', ')}
        ref="fields"
      />

      <kor-synonyms-editor
        label={tcap('activerecord.attributes.entity.synonyms')}
        name="synonyms"
        ref="fields"
        value={combined.synonyms}
      />

      <div class="hr"></div>

      <kor-input
        each={values, key in combined.dataset}
        label={fieldByKey(key).form_label}
        name={key}
        type="select"
        options={values}
        ref="dataset"
      />

      <div class="hr"></div>

      <kor-datings-editor
        if={kind}
        label={tcap('activerecord.models.entity_dating', {count: 'other'})}
        name="datings_attributes"
        ref="fields"
        value={combined.datings}
        for="entity"
        kind={kind}
      />

      <div class="hr"></div>

      <kor-entity-properties-editor
        label={tcap('activerecord.attributes.entity.properties')}
        name="properties"
        ref="fields"
        value={combined.properties}
      />

      <div class="hr"></div>

      <kor-input type="submit" />
    </form>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.noNameStatements = [
      {label: tag.t('values.no_name_statements.unknown'), value: 'unknown'},
      {label: tag.t('values.no_name_statements.not_available'), value: 'not_available'},
      {label: tag.t('values.no_name_statements.empty_name'), value: 'empty_name'},
      {label: tag.t('values.no_name_statements.enter_name'), value: 'enter_name'}
    ];

    tag.on('mount', function() {
      fetch();
      tag.update();
    })

    tag.submit = function(event) {
      event.preventDefault();
      Zepto.ajax({
        type: 'POST',
        url: '/entities/merge',
        data: JSON.stringify({
          entity_ids: tag.combined.id,
          entity: Zepto.extend(values())
        }),
        success: function(data) {
          tag.opts.modal.trigger('close');
          wApp.routing.path('/entities/' + data.id);
        }
      });
    }

    tag.fieldByKey = function(key) {
      for (var i = 0; i < tag.kind.fields.length; i++) {
        var f = tag.kind.fields[i];
        if (f.name == key) {
          return f;
        }
      }
    }

    var fetch = function() {
      // check amount of ids
      if (!tag.opts.ids || tag.opts.ids.length < 2) {
        return setError('messages.must_select_2_or_more_entities');
      }
      if (tag.opts.ids.length > 10) {
        return setError('messages.cant_merge_more_than_10_entities');
      }

      Zepto.ajax({
        type: 'GET',
        url: '/entities',
        data: {id: tag.opts.ids.join(','), include: 'all'},
        success: function(data) {
          // check not retrieved (but requested) entities
          if (data.total < tag.opts.ids.length) {
            return setError('messages.missing_entities_to_merge');
          }

          // check kind of all ids
          for (var i = 1; i < data.records.length; i++) {
            var e = data.records[i];
            if (e.kind_id != data.records[0].kind_id) {
              return setError('messages.only_same_kind');
            }
          }

          tag.data = data;
          fetchKind(tag.data.records[0].kind_id);
        }
      })
    }

    var fetchKind = function(id) {
      Zepto.ajax({
        type: 'GET',
        url: '/kinds/' + id,
        data: {include: 'fields,settings'},
        success: function(data) {
          tag.kind = data;
          combineData();
        }
      })
    }

    var combineData = function() {
      var media = [];

      // initialize combined values
      var combined = {
        id: [],
        uuid: [],
        subtype: [],
        collection_id: [],
        // no_name_statement: [],
        name: [],
        distinct_name: [],
        medium_id: [],
        comment: [],

        tags: [],
        synonyms: [],
        datings: [],
        properties: [],

        dataset: {}
      }

      // fill in values from entities
      for (var i = 0; i < tag.data.records.length; i++) {
        var e = tag.data.records[i];

        combined.id.push(e.id);
        combined.uuid.push(e.uuid);
        combined.subtype.push(e.subtype);
        combined.collection_id.push(e.collection_id);
        // combined.no_name_statement.push(e.no_name_statement);
        combined.name.push(e.name);
        combined.distinct_name.push(e.distinct_name);
        if (e.medium_id) {
          combined.medium_id.push(e.medium_id);
          media.push({image_url: e.medium.url.thumbnail, value: e.id})
        }
        combined.comment.push(e.comment);

        combined.tags = combined.tags.concat(e.tags);
        combined.datings = combined.datings.concat(e.datings);
        combined.synonyms = combined.synonyms.concat(e.synonyms);
        combined.properties = combined.properties.concat(e.properties);

        for (k in e.dataset) {
          if (!combined.dataset[k]) {
            combined.dataset[k] = [];
          }
          combined.dataset[k].push(e.dataset[k])
        }
      }

      // clean up values
      combined = cleanup(combined);

      // console.log(combined);

      tag.combined = combined;
      tag.media = media;
      tag.update();
    }

    var cleanup = function(values) {
      if (Zepto.isArray(values)) {
        if (values.length == 0) return [];
        if (Zepto.isPlainObject(values[0])) return values;
        var result = wApp.utils.uniq(values).filter(function(e) {
          return e != null && e != '';
        });
        return result.sort();
      } else {
        for (var k in values) {
          values[k] = cleanup(values[k]);
        }
      }

      return values;
    }

    var values = function() {
      var results = {dataset: {}};
      for (var i = 0; i < tag.refs.fields.length; i++) {
        var korInput = tag.refs.fields[i];
        results[korInput.name()] = korInput.value();
      }
      var df = tag.refs.dataset;
      if (df) {
        if (!Zepto.isArray(df)) {df = [df];}
        for (var i = 0; i < df.length; i++) {
          var korInput = df[i];
          results.dataset[korInput.name()] = korInput.value();
        }
      }
      return results;
    }

    var setError = function(error) {
      tag.error = error;
      tag.update();
    }
  </script>
</kor-entity-merger>