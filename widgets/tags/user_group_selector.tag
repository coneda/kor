<kor-user-group-selector>

  <kor-input
    label={tcap('activerecord.models.user_group')}
    name={opts.name}
    type="text"
    ref="input"
    riot-value={opts.riotValue}
  />

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    var ac = null;

    tag.on('mount', function() {
      ac = new autoComplete({
        selector: Zepto(tag.root).find('input')[0],
        source: function(term, response) {
          Zepto.ajax({
            url: '/user_groups',
            data: {terms: term},
            success: function(data) {
              var strings = [];
              for (var i = 0; i < data.records.length; i++)
                strings.push(data.records[i].name);
              response(strings);
            }
          })
        }
      })
    })

    tag.value = function() {
      return tag.refs['input'].value();
    }
  </script>

</kor-user-group-selector>