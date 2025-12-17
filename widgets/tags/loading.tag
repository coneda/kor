<kor-loading>
  <img show={ajaxInProgress()} src="images/loading.gif">

  <script type="text/javascript">
    let tag = this;

    tag.on('mount', function() {
      wApp.bus.on('ajax-state-changed', tag.update)
    })

    tag.off('mount', function() {
      wApp.bus.off('ajax-state-changed', tag.update)
    })    

    tag.ajaxInProgress = function() {
      return wApp.state.requests.length > 0
    }
  </script>
</kor-loading>