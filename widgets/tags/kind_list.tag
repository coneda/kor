<kor-kind-list>

  <kor-layout-panel class="left small">
    <!-- <h1>a<kor-t key="with" />b</h1> -->
    <div class="text-right">
      <a href="#" onclick={expand_all}>expand</a>
      |
      <a href="#" onclick={collapse_all}>collapse</a>
    </div>
    <div class="hr"></div>
    <kor-kind-tree />
  </kor-layout-panel>

  <kor-layout-panel class="right large">
    <kor-panel>
      <kor-kind-editor kind={kind} if={kind} />
    </kor-panel>
  </kor-layout-panel>

  <script type="text/coffee">
    tag = this

    wApp.bus.on 'angular-data-ready', (service) ->
      console.log '----', service
      tag.update()

    tag.on 'kor-kind-edit', (kind) ->
      console.log kind
      tag.kind = kind
      tag.update()

    tag.expand_all = (event) ->
      event.preventDefault() if event
      tag.trigger 'expand-all'

    tag.collapse_all = (event) ->
      event.preventDefault() if event
      tag.trigger 'collapse-all'
  </script>

</kor-kind-list>