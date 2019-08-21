<kor-relationship-editor>

  <div class="kor-content-box" if={relationship}>
    <h1 if={relationship.id}>
      {tcap('objects.edit', {interpolations: {o: 'activerecord.models.relationship'}})}
    </h1>
    <h1 if={!relationship.id}>
      {tcap('objects.create', {interpolations: {o: 'activerecord.models.relationship'}})}
    </h1>

    <form onsubmit={save} onreset={cancel} if={relationship}>
      <kor-input
        name="lock_version"
        value={relationship.lock_version || 0}
        ref="fields"
        type="hidden"
      />

      <kor-relation-selector
        source-kind-id={sourceKindId}
        target-kind-id={targetKindId}
        value={relationship.relation_name}
        errors={errors.relation_id}
        ref="relationName"
        onchange={relationChanged}
      />

      <hr />

      <kor-entity-selector
        relation-name={relationship.relation_name}
        value={relationship.to_id}
        errors={errors.to_id}
        ref="targetId"
        onchange={targetChanged}
      />

      <hr />

      <kor-properties-editor
        properties={relationship.properties}
        ref="properties"
      />

      <hr />

      <kor-datings-editor
        value={relationship.datings}
        ref="datings"
        errors={errors.datings}
        for="relationship"
        default-dating-label={config().relationship_dating_label}
      />

      <hr />

      <kor-input type="submit" />
      <kor-input type="reset" label={tcap('cancel')} />
    </form>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.editor);

    tag.resource = {
      singular: 'relationship',
      plural: 'relationships'
    }

    tag.resourceId = function() {
      return tag.relationship.relationship_id;
    }

    tag.on('mount', function() {
      tag.relationship = tag.opts.directedRelationship;
      tag.errors = {};

      if (tag.relationship.from_id) {fetchSource();}
      if (tag.relationship.to_id) {fetchTarget();}
    });

    tag.cancel = function() {
      tag.opts.modal.trigger('close');
    }

    tag.relationChanged = function() {
      tag.relationship.relation_name = tag.refs.relationName.value();
      tag.update();
      tag.refs.targetId.trigger('reload');
    }

    tag.targetChanged = function() {
      tag.relationship.to_id = tag.refs.targetId.value();
      fetchTarget();
    }

    tag.onSuccess = function() {
      tag.errors = {};
      tag.update();

      if (tag.relationship.id) {
        wApp.bus.trigger('relationship-updated');
        h = tag.opts.onUpdated;
      } else {
        wApp.bus.trigger('relationship-created');
      }

      tag.opts.modal.trigger('close');
    }

    tag.formValues = function() {
      return {
        from_id: tag.relationship.from_id,
        relation_name: tag.refs.relationName.value(),
        to_id: tag.refs.targetId.value(),
        properties: tag.refs.properties.value(),
        datings_attributes: tag.refs.datings.value()
      }
    }

    var fetchSource = function() {
      Zepto.ajax({
        url: '/entities/' + tag.relationship.from_id,
        success: function(data) {
          tag.sourceKindId = data.kind_id;
          tag.update()
          tag.refs.relationName.trigger('reload');
        }
      })
    }

    var fetchTarget = function() {
      if (tag.relationship.to_id) {
        Zepto.ajax({
          url: '/entities/' + tag.relationship.to_id,
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
  </script>

</kor-relationship-editor>