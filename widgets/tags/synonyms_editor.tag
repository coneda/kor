<kor-synonyms-editor>
  <kor-input
    label={opts.label}
    type="textarea"
    value={valueFromParent()}
  />

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.valueFromParent = ->
      if opts.riotValue then opts.riotValue.join("\n") else ''

    tag.name = -> tag.opts.name

    tag.value = ->
      text = tag.tags['kor-input'].value()
      return [] if text.match(/^\s*$/)
      
      s for s in text.split(/\n/) when s
  </script>
</kor-synonyms-editor>