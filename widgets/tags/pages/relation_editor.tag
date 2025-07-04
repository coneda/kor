<kor-relation-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.relation'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.relation'}})}
      </h1>

      <form onsubmit={submit} if={relation && possible_parents}>
        <kor-input
          name="lock_version"
          value={relation.lock_version || 0}
          ref="fields"
          type="hidden"
        />

        <kor-input
          name="schema"
          label={tcap('activerecord.attributes.relation.schema')}
          ref="fields"
        />

        <kor-input
          name="identifier"
          label={tcap('activerecord.attributes.relation.identifier')}
          riot-value={relation.identifier}
          errors={errors.identifier}
          ref="fields"
          help={tcap('help.relation_identifier')}
        />

        <kor-input
          name="reverse_identifier"
          label={tcap('activerecord.attributes.relation.reverse_identifier')}
          riot-value={relation.reverse_identifier}
          errors={errors.reverse_identifier}
          ref="fields"
          help={tcap('help.relation_identifier')}
        />

        <kor-input
          name="name"
          label={tcap('activerecord.attributes.relation.name')}
          riot-value={relation.name}
          errors={errors.name}
          ref="fields"
        />

        <kor-input
          name="reverse_name"
          label={tcap('activerecord.attributes.relation.reverse_name')}
          riot-value={relation.reverse_name}
          errors={errors.reverse_name}
          ref="fields"
        />

        <kor-input
          name="description"
          type="textarea"
          label={tcap('activerecord.attributes.relation.description')}
          riot-value={relation.description}
          ref="fields"
        />

        <kor-input
          if={possible_kinds}
          name="from_kind_id"
          type="select"
          options={possible_kinds}
          label={tcap('activerecord.attributes.relation.from_kind_id')}
          riot-value={relation.from_kind_id}
          errors={errors.from_kind_id}
          ref="fields"
        />

        <kor-input
          if={possible_kinds}
          name="to_kind_id"
          type="select"
          options={possible_kinds}
          label={tcap('activerecord.attributes.relation.to_kind_id')}
          riot-value={relation.to_kind_id}
          errors={errors.to_kind_id}
          ref="fields"
        />

        <kor-input
          name="parent_ids"
          type="select"
          options={possible_parents}
          multiple={true}
          label={tcap('activerecord.attributes.relation.parent')}
          riot-value={relation.parent_ids}
          errors={errors.parent_ids}
          ref="fields"
        />

        <kor-input
          name="abstract"
          type="checkbox"
          label={tcap('activerecord.attributes.relation.abstract')}
          riot-value={relation.abstract}
          ref="fields"
        />

        <div class="hr"></div>

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.page);

  // Before mounting, check if user is a relation admin
  tag.on('before-mount', function() {
    if (!tag.isRelationAdmin()) {
      wApp.bus.trigger('access-denied');
    }
  });

  // On mount, initialize errors, fetch data if editing, and load options
  tag.on('mount', function() {
    tag.errors = {};
    if (tag.opts.id) {
      fetch();
    } else {
      tag.relation = {};
      tag.update();
    }
    fetchPossibleParents();
    fetchPossibleKinds();
  });

  // Handle form submission for create or update
  tag.submit = function(event) {
    event.preventDefault();
    var p = tag.opts.id ? update() : create();
    p.then(function(data) {
      tag.errors = {};
      window.history.back();
    });
    p.catch(function(response) {
      tag.errors = response.data.errors;
      wApp.utils.scrollToTop();
    });
    p.finally(function() {
      tag.update();
    });
  };

  // Create a new relation
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: '/relations',
      data: JSON.stringify({ relation: values() })
    });
  };

  // Update an existing relation
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: '/relations/' + tag.opts.id,
      data: JSON.stringify({ relation: values() })
    });
  };

  // Collect form values for submission
  var values = function() {
    // TODO: add lock version functionality to all forms
    var result = {};
    for (var i = 0; i < tag.refs['fields'].length; i++) {
      var field = tag.refs['fields'][i];
      result[field.name()] = field.value();
    }
    return result;
  };

  // Fetch relation data from server
  var fetch = function() {
    Zepto.ajax({
      url: '/relations/' + tag.opts.id,
      data: { include: 'inheritance,technical' },
      success: function(data) {
        tag.relation = data;
        tag.update();
      }
    });
  };

  // Fetch possible parent relations for select options
  var fetchPossibleParents = function() {
    Zepto.ajax({
      url: '/relations',
      success: function(data) {
        tag.possible_parents = [];
        for (var i = 0; i < data.records.length; i++) {
          var relation = data.records[i];
          if (parseInt(tag.opts.id) !== relation.id) {
            tag.possible_parents.push({
              label: relation.name,
              value: relation.id
            });
          }
        }
        tag.update();
      }
    });
  };

  // Fetch possible kinds for select options
  var fetchPossibleKinds = function() {
    Zepto.ajax({
      url: '/kinds',
      success: function(data) {
        tag.possible_kinds = [];
        for (var i = 0; i < data.records.length; i++) {
          var kind = data.records[i];
          tag.possible_kinds.push({
            label: kind.name,
            value: kind.id
          });
        }
        tag.update();
      }
    });
  };

</script>
</kor-relation-editor>

