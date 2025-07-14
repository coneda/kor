<kor-kinds>

  <div class="kor-content-box">
    <a
      if={isKindAdmin()}
      href="#/kinds/new"
      class="pull-right"
      title={t('verbs.add')}
    ><i class="fa fa-plus-square"></i></a>
    <h1>{tcap('activerecord.models.kind', {count: 'other'})}</h1>

    <form class="inline">
      <kor-input
        label={tcap('search_term')}
        name="terms"
        onkeyup={delayedSubmit}
        ref="terms"
      />

      <kor-input
        label={tcap('hide_abstract')}
        type="checkbox"
        name="hideAbstract"
        onchange={submit}
        ref="hideAbstract"
      />
    </form>

    <hr />

    <virtual if={filteredRecords && filteredRecords.length}>
      <table each={records, schema in groupedResults} class="kor_table text-left">
        <thead>
          <tr>
            <th>{schema == 'null' ? tcap('no_schema') : schema}</th>
            <th if={isKindAdmin()}></th>
          </tr>
        </thead>
        <tbody>
          <tr each={kind in records}>
            <td class={active: !kind.abstract}>
              <div class="name">
                <a href="#/kinds/{kind.id}/edit">{kind.name}</a>
              </div>
              <div show={kind.fields.length}>
                <span class="label">
                  {t('activerecord.models.field', {count: 'other'})}:
                </span>
                {fieldNamesFor(kind)}
              </div>
              <div show={kind.generators.length}>
                <span class="label">
                  {t('activerecord.models.generator', {count: 'other'})}:
                </span>
                {generatorNamesFor(kind)}
              </div>
            </td>
            <td class="buttons" if={isKindAdmin()}>
              <a href="#/kinds/{kind.id}/edit" title={t('verbs.edit')}><i class="fa fa-edit"></i></a>
              <a
                if={kind.removable}
                href="#/kinds/{kind.id}"
                onclick={delete(kind)}
                title={t('verbs.delete')}
              ><i class="fa fa-remove"></i></a>
            </td>
          </tr>
        </tbody>
      </table>
    </virtual>
  </div>

<script type="text/javascript">
  var tag = this;
  tag.requireRoles = ['kind_admin'];
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.page);

  // On mount, set the title and fetch data
  tag.on('mount', function() {
    tag.title(tag.t('activerecord.models.kind', { count: 'other' }));
    fetch();
  });

  tag.filters = {};

  // Delete a kind
  tag.delete = function(kind) {
    return function(event) {
      event.preventDefault();
      if (wApp.utils.confirm(tag.t('confirm.general'))) {
        Zepto.ajax({
          type: 'DELETE',
          url: "/kinds/" + kind.id,
          success: function() {
            fetch();
          }
        });
      }
    };
  };

  // Check if the kind is media
  tag.isMedia = function(kind) {
    return kind.uuid === wApp.data.medium_kind_uuid;
  };

  // Get field names for a kind
  tag.fieldNamesFor = function(kind) {
    return kind.fields.map(function(k) {
      return k.show_label;
    }).join(', ');
  };

  // Get generator names for a kind
  tag.generatorNamesFor = function(kind) {
    return kind.generators.map(function(g) {
      return g.name;
    }).join(', ');
  };

  // Submit filters and update records
  tag.submit = function() {
    tag.filters.terms = tag.refs['terms'].value();
    tag.filters.hideAbstract = tag.refs['hideAbstract'].value();
    filterRecords();
    groupAndSortRecords();
    tag.update();
  };

  // Delayed submit for filters
  tag.delayedSubmit = function(event) {
    if (tag.delayedTimeout) {
      clearTimeout(tag.delayedTimeout);
      tag.delayedTimeout = undefined;
    }

    tag.delayedTimeout = window.setTimeout(tag.submit, 300);
    return true;
  };

  // Filter records based on terms and abstract flag
  var filterRecords = function() {
    if (tag.filters.terms) {
      var re = new RegExp(tag.filters.terms, 'i');
      var results = [];
      for (var i = 0; i < tag.data.records.length; i++) {
        var kind = tag.data.records[i];
        if (kind.name.match(re) && results.indexOf(kind) === -1) {
          results.push(kind);
        }
      }
      tag.filteredRecords = results;
    } else {
      tag.filteredRecords = tag.data.records;
    }

    if (tag.filters.hideAbstract) {
      tag.filteredRecords = tag.filteredRecords.filter(function(kind) {
        return !kind.abstract;
      });
    }
  };

  // Compare types for sorting
  var typeCompare = function(x, y) {
    if (x.match(/^E\d+/) && y.match(/^E\d+/)) {
      x = parseInt(x.replace(/^E/, '').split(' ')[0]);
      y = parseInt(y.replace(/^E/, '').split(' ')[0]);
    }
    if (x > y) {
      return 1;
    } else if (x === y) {
      return 0;
    } else {
      return -1;
    }
  };

  // Group and sort records by schema
  var groupAndSortRecords = function() {
    var results = {};
    for (var i = 0; i < tag.filteredRecords.length; i++) {
      var r = tag.filteredRecords[i];
      if (!results[r.schema]) {
        results[r.schema] = [];
      }
      results[r.schema].push(r);
    }
    for (var k in results) {
      results[k] = results[k].sort(function(x, y) {
        return typeCompare(x.name, y.name);
      });
    }
    tag.groupedResults = results;
  };

  // Fetch kinds data from the server
  var fetch = function() {
    Zepto.ajax({
      url: '/kinds',
      data: { include: 'generators,fields,inheritance' },
      success: function(data) {
        tag.data = data;
        filterRecords();
        groupAndSortRecords();
        tag.update();
      }
    });
  };
</script>

</kor-kinds>