<kor-generator>

  <script type="text/coffee">
    tag = this

    update = ->
      try
        tpl = tag.opts.generator.directive
        data = {entity: tag.opts.entity}
        Zepto(tag.root).html render(tpl, data)
      catch e
        # console.error(
        #   "there was an error rendering tpl '#{tpl}' with data:", data, e
        # )

    tag.on 'mount', update
    tag.on 'updated', update

    render = riot.util.tmpl
  </script>

</kor-generator>