<kor-relation-selector>
  <kor-input
    if="{relationNames && relationNames.length > 0}"
    name="relation_name"
    label={tcap('activerecord.models.relation')}
    type="select"
    placeholder={t('nothing_selected')}
    options={relationNames}
    value={opts.riotValue}
    errors={opts.errors}
    ref="input"
    onchange={onchange}
  />

  <em
    if={relationNames && relationNames.length == 0}
    class="error"
  >{t('messages.no_relations_provided')}</em>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      tag.trigger('reload');
    });

    tag.on('reload', function() {
      fetch();
    });

    tag.onchange = function(event) {
      event.stopPropagation();
      var h = tag.opts.onchange;
      if (h) {h();}
    }

    tag.value = function() {
      var i = tag.refs.input;
      return i ? i.value() : null;
    }

    var fetch = function() {
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
      });
    }

  </script>
</kor-relation-selector>