<kor-relationship-editor>

  <h1>{header()}</h1>

  <form onsubmit={save}>
    <kor-relation-selector
      source-kind-id={sourceKindId}
      target-kind-id={targetKindId}
      value={opts.relationship.relation_name}
      errors={errors.relation_id}
      ref="relation_name"
    />

    <kor-entity-selector
      relation-name={relationName}
      errors={errors.to_id}
      value={opts.relationship.to}
      ref="target_id"
    />

    <div class="hr"></div>

    <kor-properties-editor
      properties={opts.relationship.properties}
      ref="properties"
    />

    <div class="hr"></div>

    <kor-datings-editor
      datings={opts.relationship.datings}
      ref="datings"
    />

    <div class="hr"></div>

    <kor-input type="submit" value={t('verbs.save')} />
    <kor-input type="reset" value={t('cancel')} />
  </form>

    <!-- <div class="kor-errors" ng-if="errors">
      <div ng-show="errors.to_id || errors.from_id">
        {{'activerecord.attributes.relationship.to_id' | translate | capitalize}}
        {{'activerecord.errors.messages.can_not_be_empty'| translate}}
      </div>
        {{'activerecord.attributes.relationship.relation_id' | translate | capitalize}}
        {{'activerecord.errors.messages.can_not_be_empty'| translate}}
      </div>
      <div ng-show="errors.datings">
        {{'activerecord.attributes.relationship.dating' | translate | capitalize}}
        {{'activerecord.errors.messages.invalid'| translate}}
      </div>
    </div>

    <div class="kor-field">
      <label ng-bind="'activerecord.attributes.relationship.relation_id' | translate | capitalize"></label>
      <div
        kor-relation-selector="relation_name"
        kor-source="source"
        kor-target="target"
      ></div>
    </div>

    <div class="kor-field">
      <label ng-bind="'activerecord.attributes.relationship.to_id' | translate | capitalize"></label>
      <div
        kor-entity-selector="target"
        kor-existing="{{existing}}"
        kor-grid-width="{{grid_width}}"
        kor-relation-name="relation_name"
      ></div>
    </div>

  </form> -->

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.errors = {}

    tag.on 'update', ->
      tag.sourceKindId = tag.opts.source.kind_id
      tag.targetKindId = tag.opts.target.kind_id
      tag.relationName = tag.opts.relationship.relation_name

    tag.on 'updated', ->
      tag.refs['relation_name'].trigger 'criteria-changed'
      tag.refs['target_id'].trigger 'criteria-changed'

    tag.submit = (event) ->
      event.preventDefault()
      if tag.opts.relationship
        Zepto.ajax(
          type: 'PATCH'
          url: "/relationships/#{tag.opts.relationship.id}"
          data: {relationship: values()}
          success: (data) ->
            h() if h = tag.opts.doneHandler
          error: (xhr) ->
            tag.errors = JSON.parse(xhr.responseText).errors
            wApp.utils.scrollToTop()
        )

    tag.values = ->
      return {
        properties: tag.refs.properties.value()
        datings: tag.refs.datings.value()
        relation_name: tag.refs.relation_name.value()
      }

    tag.header = ->
      key = if !!tag.opts.relationship then 'edit' else 'create'
      tag.t("objects.#{key}", {
        interpolations: {o: 'activerecord.models.relationship'},
        capitalize: true
      })

  </script>

</kor-relationship-editor>