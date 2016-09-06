<kor-kind-list>

  <h1>a<kor-t key="to" />b</h1>

  <!-- collapse_all -->

  <kor-kind-tree />

  <script type="text/coffee">
    tag = this
    window.t = tag

    wApp.bus.on 'angular-data-ready', (service) ->
      console.log '----', service
  </script>

</kor-kind-list>