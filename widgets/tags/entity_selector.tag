<kor-entity-selector>
  <div class="pull-right">
    <a
      href="#"
      onclick={gotoTab('search')}
      class="{'selected': currentTab == 'search'}"
    >{t('nouns.search')}</a>
    |
    <a
      href="#"
      onclick={gotoTab('visited')}
      class="{'selected': currentTab == 'visited'}"
    >{t('recently_visited')}</a>
    |
    <a
      href="#"
      onclick={gotoTab('created')}
      class="{'selected': currentTab == 'created'}"
    >{t('recently_created')}</a>
    <virtual if={existing}>
      |
      <a
        href="#"
        onclick={gotoTab('current')}
        class="{'selected': currentTab == 'current'}"
      >{t('currently_linked')}</a>
    </virtual>
  </div>

  <div class="header">
    <label>{opts.label || tcap('activerecord.models.entity')}</label>
  </div>

  <kor-input
    if={currentTab == 'search'}
    name="terms"
    placeholder={tcap('nouns.term')}
    ref="terms"
    onkeyup={search}
  />

  <kor-pagination
    if={data}
    page={page}
    per-page={9}
    total={data.total}
    on-paginate={paginate}
  />

  <table if={!!groupedEntities}>
    <tbody>
      <tr each={row in groupedEntities}>
        <td
          each={record in row}
          onclick={select}
          class="{selected: isSelected(record)}"
        >
          <kor-entity
            if={record}
            entity={record}
          />
        </td>
      </tr>
    </tbody>
  </table>

  <div class="errors" if={opts.errors}>
    <div each={e in opts.errors}>{e}</div>
  </div>

 <script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.page = 1;

  // Before mounting, initialize values and trigger reload
  tag.on('before-mount', function() {
    tag.id = tag.opts.riotValue;
    if (tag.id) {
      tag.existing = true;
    }

    tag.currentTab = tag.id ? 'current' : 'search';
    tag.trigger('reload');
    tag.update();
  });

  // Reload data
  tag.on('reload', function() {
    fetch();
  });

  // Switch tabs
  tag.gotoTab = function(newTab) {
    return function(event) {
      event.preventDefault();
      if (tag.currentTab !== newTab) {
        tag.currentTab = newTab;
        tag.data = {};
        tag.groupedEntities = [];
        fetch();
        tag.update();
      }
    };
  };

  // Check if a record is selected
  tag.isSelected = function(record) {
    return record && tag.id === record.id;
  };

  // Select or deselect a record
  tag.select = function(event) {
    event.preventDefault();
    var record = event.item.record;
    if (tag.isSelected(record)) {
      tag.id = undefined;
    } else {
      tag.id = record.id;
    }
    if (tag.opts.onchange) {
      tag.opts.onchange();
    }
  };

  // Search with debounce
  tag.search = function() {
    if (tag.to) {
      window.clearTimeout(tag.to);
    }
    tag.to = window.setTimeout(fetch, 300);
  };

  // Paginate results
  tag.paginate = function(newPage) {
    tag.page = newPage;
    fetch();
  };

  // Get the current value
  tag.value = function() {
    return tag.id;
  };

  // Fetch data based on the current tab
  function fetch() {
    switch (tag.currentTab) {
      case 'current':
        if (tag.opts.riotValue) {
          Zepto.ajax({
            url: '/entities/' + tag.opts.riotValue,
            success: function(data) {
              tag.data = { records: [data] };
              group();
            }
          });
        }
        break;
      case 'visited':
        Zepto.ajax({
          url: '/entities',
          data: {
            id: wApp.entityHistory.ids(),
            relation_name: tag.opts.relationName,
            page: tag.page,
            per_page: 9
          },
          success: function(data) {
            tag.data = data;
            group();
          }
        });
        break;
      case 'created':
        Zepto.ajax({
          url: '/entities',
          data: {
            relation_name: tag.opts.relationName,
            page: tag.page,
            per_page: 9,
            sort: 'created_at',
            direction: 'desc'
          },
          success: function(data) {
            tag.data = data;
            group();
          }
        });
        break;
      case 'search':
        if (tag.refs.terms) {
          Zepto.ajax({
            url: '/entities',
            data: {
              terms: tag.refs.terms.value(),
              relation_name: tag.opts.relationName,
              per_page: 9,
              page: tag.page
            },
            success: function(data) {
              tag.data = data;
              group();
            }
          });
        }
        break;
    }
  }

  // Group entities into rows of 3
  function group() {
    tag.groupedEntities = wApp.utils.inGroupsOf(3, tag.data.records, null);
    tag.update();
  }
</script>

</kor-entity-selector>