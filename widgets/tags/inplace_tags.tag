<kor-inplace-tags>
  <virtual if={opts.entity.tags.length > 0 || opts.enableEditor}>
    <span class="field">
      {tcap('activerecord.models.tag', {count: 'other'})}:
    </span>
    <span class="value">
      <a
        each={tag, i in opts.entity.tags}
        href="#/search?tags={tag}"
      >{i === 0 ? '' : ', '}{tag}</a>
  </virtual>

  <virtual if={opts.enableEditor}>
    <a
      show={!editorActive}
      onclick={toggleEditor}
      href="#"
      title={t('edit_tags')}
    ><i class="fa fa-plus-square"></i></a>

    <virtual if={editorActive}>
      <kor-input
        name="tags"
        ref="field"
      />

      <button onclick={save}>{tcap('verbs.save')}</button>
      <button onclick={cancel}>{tcap('cancel')}</button>
    </virtual>
  </virtual>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.toggleEditor = (event) ->
      event.preventDefault() if event
      tag.editorActive = !tag.editorActive

    tag.save = (event) ->
      event.preventDefault()
      Zepto.ajax(
        type: 'PATCH'
        url: "/entities/#{tag.opts.entity.id}/update_tags"
        data: JSON.stringify(entity: {tags: tag.refs.field.value()})
        success: (data) ->
          tag.toggleEditor()
          tag.update()
          h() if h = tag.opts.handlers.doneHandler
      )

    tag.cancel = (event) ->
      event.preventDefault()
      tag.editorActive = false
  </script>
</kor-inplace-tags>