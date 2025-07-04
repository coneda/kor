<kor-generator>
<script type="text/javascript">
  var tag = this;

  // Update the DOM with rendered template
  var update = function() {
    try {
      var tpl = tag.opts.generator.directive;
      var data = { entity: tag.opts.entity };
      Zepto(tag.root).html(render(tpl, data));
    } catch (e) {
      console.error(
        "there was an error rendering tpl '" + tpl + "' with data:", data, e
      );
    }
  };

  tag.on('mount', update);
  tag.on('updated', update);

  // Use ejs.render for template rendering
  var render = ejs.render;
</script>
</kor-generator>