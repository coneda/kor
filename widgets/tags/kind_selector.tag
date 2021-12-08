<kor-kind-selector>

  <kor-input
    if={kinds}
    label={tcap('activerecord.models.kind')}
    type="select"
    ref="input"
    options={kinds}
    placeholder={t('all')}
    value={opts.riotValue}
  />

  </kor-input>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
    })

    tag.name = function() {
      return tag.opts.name;
    }

    tag.value = function() {
      var v = tag.refs.input.value();
      if (v) {
        return parseInt(v);
      } else {
        return v;
      }
    }

    tag.set = function(value) {
      if (tag.refs.input) {
        tag.refs.input.set(value);
      } else {
        tag.kind_id = value;
      }
    }

    tag.reset = function() {
      tag.set(null);
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/kinds',
        success: function(data) {
          var results = [];
          for (var i = 0; i < data.records.length; i++) {
            var k = data.records[i];
            if (tag.opts.includeMedia || k.id != wApp.info.data.medium_kind_id) {
              results.push(k);
            }
          }
          tag.kinds = results;
          tag.update();

          if (tag.kind_id) {
            tag.refs.input.set(tag.kind_id);
            tag.kind_id = null;
          }
        }
      })
    }
  </script>

</kor-kind-selector>