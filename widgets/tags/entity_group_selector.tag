<kor-entity-group-selector>

  <kor-input
    label={tcap('activerecord.models.' + opts.type + '_group')}
    name={opts.name}
    placeholder={t('prompts.autocomplete')}
    type="text"
    ref="input"
    riot-value={opts.riotValue}
    errors={opts.errors}
  />

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    var ac = null;

    tag.on('mount', function() {
      ac = new autoComplete({
        selector: Zepto(tag.root).find('input')[0],
        minChars: 1,
        source: function(term, response) {
          Zepto.ajax({
            url: '/' + tag.opts.type + '_groups',
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

    tag.name = function() {
      return tag.opts.name;
    }

    tag.value = function() {
      return tag.refs['input'].value();
    }
  </script>

</kor-entity-group-selector>