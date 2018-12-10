<kor-publishment>

  <div class="kor-content-box">
    <h1>{data.name}</h1>

    <div class="hr"></div>

    <kor-gallery-grid
      if={data}
      entities={data.entities}
      publishment={opts.uuid}
    />

    <div class="hr"></div>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      fetch()
    })

    var fetch = function() {
      return Zepto.ajax({
        url: '/publishments/' + tag.opts.userId + '/' + tag.opts.uuid,
        data: {include: 'gallery_data'},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>

</kor-publishment>