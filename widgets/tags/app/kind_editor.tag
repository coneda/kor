<kor-kind-editor>

  <kor-layout-panel class="left small">
    <kor-panel>
      <a href="#" onclick={switchTo('general')}>
        » {wApp.i18n.translate('general', {capitalize: true})}
      </a><br />
      <a href="#" onclick={switchTo('fields')} if={opts.kind.id}>
        » {wApp.i18n.translate('activerecord.models.field', {count: 'other', capitalize: true})}
      </a><br />
      <a href="#" onclick={switchTo('generators')} if={opts.kind.id}>
        » {wApp.i18n.translate('activerecord.models.generator', {count: 'other', capitalize: true})}
      </a><br />

      <div class="hr"></div>
      <div class="text-right">
        <button onclick={closeModal}>close</button>
      </div>
    </kor-panel>
  </kor-layout-panel>

  <kor-layout-panel class="right large ">
    <kor-panel>
      <kor-kind-general-editor kind={opts.kind} if={tab == 'general'} />
      <kor-kind-fields-editor
        kind={opts.kind}
        if={tab == 'fields' && opts.kind.id}
      />
      <kor-kind-generators-editor
        kind={opts.kind}
        if={tab == 'generators' && opts.kind.id}
      />
    </kor-panel>
  </kor-layout-panel>

  <script type="text/coffee">
    tag = this
    tag.tab = 'general'

    tag.switchTo = (name) ->
      (event) ->
        tag.tab = name
        tag.update()

    tag.closeModal = ->
      if tag.opts.modal
        tag.opts.modal.trigger 'close'

  </script>

</kor-kind-editor>