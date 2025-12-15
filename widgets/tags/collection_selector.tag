<kor-collection-selector>
  <virtual if={collections}>
    <virtual if={collections.length == 1}
      <input
        ref="input"
        type="hidden"
        value={collections[0].id}
      />
    </virtual>

    <virtual if={collections && collections.length > 1}>
      <kor-input
        if={!opts.multiple}
        label={tcap('activerecord.models.collection')}
        name={opts.name}
        type="select"
        options={collections}
        ref="input"
      />

      <virtual if={opts.multiple}>
        <label>{tcap('activerecord.models.collection', {count: 'other'})}:</label>
        <strong if={!ids || ids.length == 0}>{t('all')}</strong>
        <strong if={ids && ids.length > 0}>{selectedList()}</strong>
        <a
          href="#"
          onclick={selectCollections}
          title={t('verbs.edit')}
        ><i class="fa fa-edit"></i></a>
      </virtual>
    </virtual>
  </virtual>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('before-mount', function() {
      tag.reset();
    })

    tag.on('mount', function() {
      fetch();
    })

    tag.reset = function() {
      tag.ids = tag.opts.riotValue || [];
    }

    tag.name = function() {
      return tag.opts.name;
    }

    tag.value = function() {
      if (tag.collections.length == 1) {
        var id = tag.collections[0].id;
        if (tag.opts.multiple)
          return [id];
        else
          return id;
      } else {
        if (tag.opts.multiple) {
          return tag.ids;
        } else {
          return tag.refs['input'].value();
        }
      }
    }

    tag.set = function(value) {
      tag.ids = value || [];
      tag.update();
    }

    tag.selectCollections = function(event) {
      event.preventDefault();

      var cols = allowedCollections();
      var ids = tag.ids || [];
      if (ids.length == 0) {
        for (var i = 0; i < cols.length; i++) {
          ids.push(cols[i].id);
        }
      }

      wApp.bus.trigger('modal', 'kor-ask-choices', {
        choices: allowedCollections(),
        multiple: true,
        notify: newSelection,
        riotValue: ids
      })
    }

    tag.selectedList = function() {
      var all = true;
      var results = [];
      for (var i = 0; i < tag.collections.length; i++) {
        var c = tag.collections[i];
        if (tag.ids.indexOf(c.id) != -1) {
          results.push(c.name);
        } else {
          all = false;
        }
      }
      if (all) {
        return tag.t('all');
      } else {
        return results.join(', ');
      }
    }

    var newSelection = function(ids) {
      tag.ids = ids;
      Zepto(tag.root).trigger('change', [tag.ids]);
      tag.update();
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/collections',
        data: {per_page: 'max'},
        success: function(data) {
          tag.collections = data.records;
          tag.update();
        }
      })
    }

    var allowedCollections = function() {
      var allowed = wApp.session.current.user.permissions.collections[tag.opts.policy];
      // console.log(allowed, tag.opts.policy, tag.collections);
      var results = [];
      for (var i = 0; i < tag.collections.length; i++) {
        var c = tag.collections[i];
        // console.log(c.id);
        if (allowed.indexOf(c.id) != -1) {
          results.push(c);
        }
      }
      return results;
    }
  </script>
</kor-collection-selector>
