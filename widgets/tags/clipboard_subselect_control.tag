<kor-clipboard-subselect-control>
  <kor-input
    type="checkbox"
    value={checked()}
    onchange={change}
  />

  <script type="text/javascript">
    var tag = this;

    tag.checked = function() {
      return wApp.clipboard.subSelected(tag.opts.entity.id);
    }

    tag.change = function(event) {
      var e = Zepto(event.target);
      var id = tag.opts.entity.id;

      if (e.prop('checked')) {
        wApp.clipboard.subSelect(id);
      } else {
        wApp.clipboard.unSubSelect(id);
      }
    }

  </script>
</kor-clipboard-subselect-control>