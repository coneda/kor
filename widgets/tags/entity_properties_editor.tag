<kor-entity-properties-editor>
  <kor-input
    label={opts.label}
    type="textarea"
    value={valueFromParent()}
    help={tcap('help.property_input')}
    errors={opts.errors}
  />

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.valueFromParent = ->
      results = []
      if opts.riotValue
        for p in opts.riotValue
          results.push "#{p.label}: #{p.value}"

      results.join("\n")

    tag.name = -> tag.opts.name

    tag.value = ->
      text = tag.tags['kor-input'].value()
      return [] if text.match(/^\s*$/)

      results = []
      for line in text.split(/\n/)
        kv = line.split(/:/)
        results.push {
          'label': kv.shift().trim(),
          'value': kv.join(':').trim()
        }
      results

  </script>
</kor-entity-properties-editor>