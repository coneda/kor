<kor-collection-selector>

  <virtual if={data}>
    <kor-input
      if={!opts.multiple}
      label={tcap('activerecord.models.collection')}
      name={opts.name}
      type="select"
      options={data.records}
      ref="input"
    />
  </virtual>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
    })

    tag.val = function() {
      return tag.refs['input'].value();
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/collections',
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

    // for later
    // tag.selectCollection = function(event) {
    //   event.preventDefault();
    //   wApp.bus.trigger('modal', 'kor-collection-selector', {policy: 'create'})
    // }
  </script>


</kor-collection-selector>