<kor-submit>

  <input type="submit" value="save">

  <script type="text/coffee">
    tag = this

    tag.label = -> wApp.i18n.t("verbs.save", capitalize: true)
  </script>
  
</kor-submit>