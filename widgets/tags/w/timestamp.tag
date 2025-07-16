<w-timestamp>
  <span>{formatted()}</span>

  <script type="text/javascript">
    var tag = this;

    tag.formatted = function() {
      if (tag.opts.value) {
        var ts = new Date(tag.opts.value);
        return strftime('%B %d, %Y %H:%M:%S', ts);
      } else {
        return null;
      }
    };
  </script>
</w-timestamp>