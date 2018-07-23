<kor-collection-selector>

  <virtual if={collections}>
    <kor-input
      if={!opts.multiple}
      label={tag.opts.labeltcap('activerecord.models.collection')}
      name={opts.name}
      type="select"
      options={collections}
      ref="input"
    />

    <virtual if={opts.multiple}>
      <label>{tcap('activerecord.models.collection', {count: 'other'})}:</label>
      <strong if={ids.length == 0}>{t('all')}</strong>
      <strong if={ids.length > 0}>{selectedList()}</strong>
      <a onclick={selectCollections}><i class="fa fa-edit"></i></a>
    </virtual>
  </virtual>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('before-mount', function() {
      tag.ids = tag.opts.riotValue || [];
    })

    tag.on('mount', function() {
      fetch();
    })

    tag.name = function() {
      return tag.opts.name;
    }

    tag.value = function() {
      if (tag.opts.multiple) {
        return tag.ids;
      } else {
        return tag.refs['input'].value();
      }
    }

    tag.selectCollections = function(event) {
      event.preventDefault();
      wApp.bus.trigger('modal', 'kor-ask-choices', {
        choices: allowedCollections(),
        multiple: true,
        notify: newSelection,
        riotValue: tag.ids
      })
    }

    tag.selectedList = function() {
      var results = [];
      for (var i = 0; i < tag.collections.length; i++) {
        var c = tag.collections[i];
        if (tag.ids.indexOf(c.id) != -1) {
          results.push(c.name);
        }
      }
      return results.join(', ');
    }

    var newSelection = function(ids) {
      tag.ids = ids;
      tag.update();
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/collections',
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