<kor-submit>

  <input type="submit" value={label()} />

  <script type="text/coffee">
    tag = this

    tag.label = ->
      tag.opts.labelKey ||= "verbs.save"
      wApp.i18n.t(tag.opts.labelKey, capitalize: true)
  </script>
  
</kor-submit>