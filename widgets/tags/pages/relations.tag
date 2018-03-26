<kor-relations>

  <div class="kor-content-box">
    <a href="#/relations/new" class="pull-right"><i class="plus"></i></a>
    <h1>{tcap('activerecord.models.relation', {count: 'other'})}</h1>

    <form onsubmit={delayedSubmit} class="inline">

      <kor-input
        label={tcap('search_term', {count: 'other'})}
        name="terms"
        onkeyup={delayedSubmit}
        ref="terms"
      />

      <div class="hr"></div>
    </form>

    <div if={filteredRecords && !filteredRecords.length}>
      {tcap('objects.none_found', {
        interpolations: {o: 'activerecord.models.relation.other'},
      })}
    </div>

    <table each={records, schema in groupedResults}>
      <thead>
        <tr>
          <th>{!schema ? t('no_schema') : schema}</th>
          <th>
            {tcap('activerecord.attributes.relation.from_kind_id')}
            {tcap('activerecord.attributes.relation.to_kind_id')}
          </th>
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
                {t('activerecord.attributes.relationship.from_id')}:
              </span>
              {kind(relation.from_kind_id)}
            </div>
            <div if={kindLookup}>
              <span class="label">
                {t('activerecord.attributes.relationship.to_id')}:
              </span>
              {kind(relation.to_kind_id)}
            </div>
          </td>
          <td class="kor-text-right">
            <a href="#/relations/{relation.id}/edit"><i class="fa fa-edit"></i></a>
            <a
              if={relation.removable}
              href="#/relations/{relation.id}"
              onclick={onDeleteClicked}
            ><i class="fa fa-remove"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <script type="text/javascript">
    tag = this;
    // reenable this functionality
    // tag.requireRoles = ['relation_admin'];
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.filters = {};

    tag.on('mount', function() {
      fetch();
      fetchKinds();
    })

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      if (wApp.utils.confirm())
        destroy(event.item.relation.id);
    }

    tag.delayedSubmit = function(event) {
      event.preventDefault();
      if (tag.delayedTimeout) {
        window.clearTimeout(tag.delayedTimeout);
        tag.delayedTimeout = undefined;
      }
      // TODO: setTimeout should bot be called from window directly (testing)
      tag.delayedTimeout = window.setTimeout(submit, 300);
      return true;
    }

    tag.kind = function(id) {return tag.kindLookup[id].name}

    var submit = function() {
      tag.filters.terms = tag.refs['terms'].value();
      filterRecords();
      groupAndSortRecords();
      tag.update();
    }

    var filterRecords = function() {
      if (tag.filters.terms) {
        re = new RegExp(tag.filters.terms, 'i');
        results = [];
        for (var i = 0; i < tag.data.records.length; i++) {
          var relation = tag.data.records[i];
          if (relation.name.match(re) || relation.reverse_name.match(re)) {
            if (results.indexOf(relation) == -1) {
              results.push(relation);
            }
          }
        }
        tag.filteredRecords = results;
      } else 
        tag.filteredRecords = tag.data.records;
    }

    var typeCompare = function(x, y) {
      if (x.match(/^P\d+/) && y.match(/^P\d+/)) {
        x = parseInt(x.replace(/^P/, '').split(' ')[0])
        y = parseInt(y.replace(/^P/, '').split(' ')[0])
      }

      if (x > y)
        return 1;
      else
        if (x == y)
          0
        else
          -1
    }

    var groupAndSortRecords = function() {
      var results = {};
      for (var i = 0; i < tag.filteredRecords.length; i++) {
        var r = tag.filteredRecords[i];
        results[r['schema']] = results[r['schema']] || [];
        results[r['schema']].push(r);
      }
      for (var k in results)
        if (results.hasOwnProperty(k)) {
          var v = results[k];
          results[k] = v.sort(function(x, y){return typeCompare(x.name, y.name)})
        }
      tag.groupedResults = results;
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/relations',
        data: {include: 'inheritance'},
        success: function(data) {
          tag.data = data;
          filterRecords();
          groupAndSortRecords();
          tag.update();
        }
      })
    }

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
      })
    }

    var destroy = function(id) {
      Zepto.ajax({
        type: 'DELETE',
        url: '/relations/' + id,
        success: fetch,
        error: function(xhr) {
          tag.errors = JSON.parse(xhr.responseText).errors;
          wApp.utils.scrollToTop();
        }
      })
    }

  </script>

</kor-relations>