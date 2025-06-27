<kor-about>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <div class="target"></div>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      tag.title(tag.t('about'));
      Zepto(tag.root).find('.target').html(tag.config().about_html);
    });
  </script>
</kor-about>
