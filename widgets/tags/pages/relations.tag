<kor-relations>

  <div class="kor-content-box">
    <div class="pull-right" if={isRelationAdmin()}>
      <a
        href="#"
        title={t('verbs.merge')}
        onclick={toggleMerge}
      ><i class="fa fa-compress" aria-hidden="true"></i></a>
      <a
        href="#/relations/new"
        title={t('verbs.add')}
      ><i class="fa fa-plus-square"></i></a>
    </div>

    <h1>
      {tcap('activerecord.models.relation', {count: 'other'})}
    </h1>

    <form class="inline" onsubmit={noSubmit}>
      <kor-input
        name="terms"
        label={tcap('search_term')}
        onkeyup={delayedSubmit}
        ref="terms"
      />

      <kor-input
        label={tcap('hide_abstract')}
        type="checkbox"
        name="hideAbstract"
        onchange={delayedSubmit}
        ref="hideAbstract"
      />

    </form>

    <hr />

    <div show={merge}>
      <div class="hr"></div>
      <kor-relation-merger ref="merger" on-done={mergeDone} />
      <div class="hr"></div>
    </div>

    <div if={filteredRecords && !filteredRecords.length}>
      {tcap('objects.none_found', {interpolations: {o: 'activerecord.models.relation.other'}})}
    </div>

    <table
      class="kor_table text-left"
      each={records, schema in groupedResults}
    >
      <thead>
        <tr>
          <th>
            {tcap('activerecord.attributes.relation.name')}
            <span if={schema == 'null' || !schema}>
              ({t('no_schema')})
            </span>
            <span if={schema && schema != 'null'}>
              ({tcap('activerecord.attributes.relation.schema')}: {schema})
            </span>
          </th>
          <th>
            {tcap('activerecord.attributes.relation.from_kind_id')}<br />
            {tcap('activerecord.attributes.relation.to_kind_id')}
          </th>
          <th if={isRelationAdmin()}></th>
        </tr>
      </thead>
      <tbody>
        <tr each={relation in records}>
          <td>
            <a href="#/relations/{relation.id}/edit">
              {relation.name} / {relation.reverse_name}
            </a>
          </td>
          <td>
            <div if={kindLookup}>
              <span class="label">
                {tcap('activerecord.attributes.relationship.from_id')}:
              </span>
              {kind(relation.from_kind_id)}
            </div>
            <div if={kindLookup}>
              <span class="label">
                {tcap('activerecord.attributes.relationship.to_id')}:
              </span>
              {kind(relation.to_kind_id)}
            </div>
          </td>
          <td class="kor-text-right buttons" if={isRelationAdmin()}>
            <a
              href="#/relations/{relation.id}/edit"
              title={t('verbs.edit')}
            ><i class="fa fa-pencil"></i></a>
            <a
              if={merge}
              href="#"
              onclick={addToMerge}
              title={t('add_to_merge')}
            ><i class="fa fa-compress"></i></a>
            <a
              href="#"
              onclick={invert}
              title={t('verbs.invert')}
            ><i class="fa fa-exchange"></i></a>
            <a
              if={relation.removable}
              href="#/relations/{relation.id}"
              onclick={delete(relation)}
              title={t('verbs.delete')}
            ><i class="fa fa-trash"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.page);

  // On mount, set title and fetch data
  tag.on('mount', function() {
    tag.title(tag.t('activerecord.models.relation', {count: 'other'}));
    fetch();
    fetchKinds();
  });

  // Filters object for search and options
  tag.filters = {};

  // Delete a relation
  tag.delete = function(kind) {
    return function(event) {
      event.preventDefault();
      if (wApp.utils.confirm(tag.t('confirm.general'))) {
        Zepto.ajax({
          type: 'DELETE',
          url: "/relations/" + kind.id,
          success: function() { fetch(); }
        });
      }
    };
  };

  // Handle filter form submit
  tag.submit = function() {
    tag.filters.terms = tag.refs['terms'].value();
    tag.filters.hideAbstract = tag.refs['hideAbstract'].value();
    filter_records();
    groupAndSortRecords();
    tag.update();
  };

  // Delayed submit for search input
  tag.delayedSubmit = function(event) {
    if (tag.delayedTimeout) {
      clearTimeout(tag.delayedTimeout);
      tag.delayedTimeout = undefined;
    }
    tag.delayedTimeout = window.setTimeout(tag.submit, 300);
    return true;
  };

  // Prevent default form submit
  tag.noSubmit = function(event) { event.preventDefault(); };

  // Toggle merge mode
  tag.toggleMerge = function(event) {
    event.preventDefault();
    tag.merge = !tag.merge;
  };

  // Add a relation to the merger
  tag.addToMerge = function(event) {
    event.preventDefault();
    tag.refs.merger.addRelation(event.item.relation);
  };

  // Finish merging
  tag.mergeDone = function() {
    tag.merge = false;
    fetch();
  };

  // Invert a relation
  tag.invert = function(event) {
    event.preventDefault();
    var relation = event.item.relation;
    if (window.confirm(tag.t('confirm.long_time_warning'))) {
      Zepto.ajax({
        type: 'PUT',
        url: '/relations/' + relation.id + '/invert',
        success: function(data) { fetch(); }
      });
    }
  };

  // Filter records based on search terms and options
  var filter_records = function() {
    if (tag.filters.terms) {
      var re = new RegExp(tag.filters.terms, 'i');
      var results = [];
      for (var i = 0; i < tag.data.records.length; i++) {
        var relation = tag.data.records[i];
        if ((relation.name && relation.name.match(re)) ||
            (relation.reverse_name && relation.reverse_name.match(re))) {
          if (results.indexOf(relation) === -1) {
            results.push(relation);
          }
        }
      }
      tag.filteredRecords = results;
    } else {
      tag.filteredRecords = tag.data.records;
    }
  };

  // Compare relation types for sorting
  var typeCompare = function(x, y) {
    if (/^P\d+/.test(x) && /^P\d+/.test(y)) {
      x = parseInt(x.replace(/^P/, '').split(' ')[0]);
      y = parseInt(y.replace(/^P/, '').split(' ')[0]);
    }
    if (x > y) return 1;
    if (x === y) return 0;
    return -1;
  };

  // Group and sort records by schema
  var groupAndSortRecords = function() {
    var results = {};
    for (var i = 0; i < tag.filteredRecords.length; i++) {
      var r = tag.filteredRecords[i];
      var schema = r['schema'];
      if (!results[schema]) results[schema] = [];
      results[schema].push(r);
    }
    for (var k in results) {
      if (results.hasOwnProperty(k)) {
        results[k] = results[k].sort(function(x, y) {
          return typeCompare(x.name, y.name);
        });
      }
    }
    tag.groupedResults = results;
  };

  // Get kind name by id
  tag.kind = function(id) {
    return tag.kindLookup[id].name;
  };

  // Fetch relations from server
  var fetch = function() {
    Zepto.ajax({
      url: '/relations',
      data: { include: 'inheritance' },
      success: function(data) {
        tag.data = data;
        filter_records();
        groupAndSortRecords();
        tag.refs.merger.reset();
        tag.update();
      }
    });
  };

  // Fetch kinds from server
  var fetchKinds = function() {
    Zepto.ajax({
      url: '/kinds',
      success: function(data) {
        tag.kindLookup = {};
        for (var i = 0; i < data.records.length; i++) {
          var k = data.records[i];
          tag.kindLookup[k.id] = k;
        }
        tag.update();
      }
    });
  };
</script>

</kor-relations>
