<kor-help>

  <div class="kor-content-box" ref="target"></div>

  <script type="text/javascript">
    let tag = this;

    tag.on('mount', function() {
      var help = wApp.config.helpFor(tag.opts.key);
      Zepto(tag.refs.target).html(help);
    })
  </script>

</kor-help>