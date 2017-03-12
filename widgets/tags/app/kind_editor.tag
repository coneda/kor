<kor-kind-editor>

  <kor-layout-panel class="left small" if={opts.kind}>
    <kor-panel>
      <h1>
        <span show={opts.kind.id}>{opts.kind.name}</span>
        <kor-t
          show={!opts.kind.id}
          key="objects.create"
          with={ {'interpolations': {'o': wApp.i18n.translate('activerecord.models.kind')}} }
        />
      </h1>

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
        <a href="#/kinds" class="kor-button">{wApp.i18n.t('back_to_list')}</a>
      </div>

      <div class="hr" if={tab == 'fields' || tab == 'generators'}></div>

      <kor-fields
        kind={opts.kind}
        if={tab == 'fields'}
        notify={notify}
      />

      <kor-generators
        kind={opts.kind}
        if={tab == 'generators'}
        notify={notify}
      />
    </kor-panel>
  </kor-layout-panel>

  <kor-layout-panel class="right large">
    <kor-panel>
      <kor-kind-general-editor
        if={tab == 'general'}
        kind={opts.kind}
        notify={notify}
      />
      <kor-field-editor
        kind={opts.kind}
        if={tab == 'fields' && opts.kind.id}
        notify={notify}
      />
      <kor-generator-editor
        kind={opts.kind}
        if={tab == 'generators' && opts.kind.id}
        notify={notify}
      />
    </kor-panel>
  </kor-layout-panel>

  <script type="text/coffee">
    tag = this
    tag.tab = 'general'
    tag.notify = riot.observable()

    tag.on 'mount', ->
      if tag.opts.id
        Zepto.ajax(
          url: "/kinds/#{tag.opts.id}"
          data: {include: 'fields,generators'}
          success: (data) ->
            tag.opts.kind = data
            tag.update()
        )
      else
        tag.opts.kind = {}

    tag.on 'kind-changed', (new_kind) ->
      tag.opts.kind = new_kind
      tag.update()

    tag.switchTo = (name) ->
      (event) ->
        event.preventDefault()
        tag.tab = name
        tag.update()

    tag.closeModal = ->
      if tag.opts.modal
        tag.opts.modal.trigger 'close'
        window.location.reload()

  </script>

</kor-kind-editor>