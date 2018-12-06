<!-- TODO: when the relation selector is set to a neutral value, the entity
selector doesn't take the source entities' kind id into account and simply
shows all entities as possible targets -->

<kor-mass-relate>

  <div class="kor-content-box">
    <h1>{tcap('clipboard_actions.mass_relate')}</h1>

    <div if={error} class="error">{tcap(error)}</div>

    <form onsubmit={save} onreset={cancel}>

      <virtual if={data}>
        <kor-relation-selector
          source-kind-id={sourceKindId}
          target-kind-id={targetKindId}
          errors={errors.relation_id}
          ref="relationName"
          onchange={relationChanged}
        />

        <hr />

        <kor-entity-selector
          relation-name={relation_name}
          errors={errors.to_id}
          ref="targetId"
          onchange={targetChanged}
        />

        <hr />

        <kor-properties-editor
          ref="properties"
        />

        <hr />

        <kor-datings-editor
          ref="datings"
          errors={errors.datings}
          for="relationship"
        />

        <hr />

        <kor-input type="submit" value={tcap('verbs.save')} />

      </virtual>

      <kor-input type="reset" value={tcap('cancel')} />
    </form>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.editor);

    tag.on('mount', function() {
      tag.errors = {};
      fetch();
    });

    tag.save = function(event) {
      event.preventDefault();

      Zepto.ajax({
        type: 'POST',
        url: '/entities/' + tag.to_id + '/mass_relate',
        data: JSON.stringify({
          entity_ids: tag.opts.ids,
          relation_name: tag.relation_name
        }),
        success: function(data) {
          tag.opts.modal.trigger('close');
        }
      });
    }

    tag.cancel = function() {
      tag.opts.modal.trigger('close');
    }

    tag.relationChanged = function() {
      tag.relation_name = tag.refs.relationName.value();
      tag.update();
      tag.refs.targetId.trigger('reload');
    }

    tag.targetChanged = function() {
      tag.to_id = tag.refs.targetId.value();
      fetchTarget();
    }

    tag.formValues = function() {
      return {
        from_id: tag.from_id,
        relation_name: tag.refs.relationName.value(),
        to_id: tag.refs.targetId.value(),
        properties: tag.refs.properties.value(),
        datings_attributes: tag.refs.datings.value()
      }
    }

    var fetch = function() {
      // check amount of ids
      if (!tag.opts.ids || tag.opts.ids.length < 1) {
        return setError('errors.must_select_1_or_more_entities');
      }
      if (tag.opts.ids.length > 10) {
        return setError('errors.cant_merge_more_than_10_entities');
      }

      Zepto.ajax({
        type: 'GET',
        url: '/entities',
        data: {id: tag.opts.ids.join(',')},
        success: function(data) {
          // check not retrieved (but requested) entities
          if (data.total < tag.opts.ids.length) {
            return setError('errors.missing_entities_to_merge');
          }

          // check kind of all ids
          for (var i = 1; i < data.records.length; i++) {
            var e = data.records[i];
            if (e.kind_id != data.records[0].kind_id) {
              return setError('errors.only_same_kind');
            }
          }

          tag.data = data;
          tag.sourceKindId = [];
          for (var i = 0; i < data.records.length; i++) {
            tag.sourceKindId.push(data.records[i].kind_id);
          }

          tag.update();
        }
      })
    }

    var fetchTarget = function() {
      if (tag.to_id) {
        Zepto.ajax({
          url: '/entities/' + tag.to_id,
          success: function(data) {
            tag.targetKindId = data.kind_id;
            tag.update()
            tag.refs.relationName.trigger('reload');
          }
        })
      } else {
        tag.targetKindId = null;
        tag.update();
        tag.refs.relationName.trigger('reload')
      }
    }

    var setError = function(error) {
      tag.error = error;
      tag.update();
    }
  </script>

</kor-mass-relate>