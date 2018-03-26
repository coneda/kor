<kor-relation-selector>

  <kor-input
    label={tcap('activerecord.models.relation')}
    type="select"
    placeholder={t('nothing_selected')}
    options={relationNames}
    value={opts.riotValue}
    ref="input"
  >

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('endpoints-changed', function() {
      Zepto.ajax({
        url: '/relations/names',
        data: {
          from_kind_ids: tag.opts.sourceKindId,
          to_kind_ids: tag.opts.targetKindId
        },
        success: function(data) {
          tag.relationNames = data;
          tag.update();
        }
      })
    });

    tag.value = function() {return tag.refs.input.value()}

  </script>

</kor-relation-selector>