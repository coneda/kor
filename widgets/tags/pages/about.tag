<kor-about>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <div class="target"></div>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.config)

    tag.on 'mount', ->
      Zepto(tag.root).find('.target').html tag.config().about_html

  </script>

</kor-about>