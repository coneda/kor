<kor-t>
  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'updated', -> Zepto(tag.root).html tag.value()

    tag.value = -> 
      tag.t(tag.opts.key, tag.opts.with || {})
  </script>
</kor-t>