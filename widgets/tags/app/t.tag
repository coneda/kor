<kor-t>
  <script type="text/coffee">
    tag = this
    tag.value = -> 
      wApp.i18n.t(tag.opts.key, tag.opts.with)
    tag.on 'updated', -> $(tag.root).html tag.value()
  </script>
</kor-t>