<kor-submit>

  <input type="submit" value={label()} />

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.label = ->
      tag.opts.labelKey ||= "verbs.save"
      tag.t(tag.opts.labelKey, capitalize: true)
  </script>
  
</kor-submit>