<kor-inplace-tags>

  <virtual if={opts.entity.tags.length > 0}>
    <span class="field">
      {tcap('activerecord.models.tag', {count: 'other'})}:
    </span>
    <span class="value">{opts.entity.tags}</span>
  </virtual>

  <virtual if={opts.enableEditor}>
    <a
      show={!editorActive}
      onclick={toggleEditor}
    ><i class="plus"></i></a>

    <virtual if={editorActive}>
      <kor-input
        name="tags"
        ref="field"
      />

      <button onclick={save}>{tcap('verbs.save')}</button>
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
  </script>

</kor-inplace-tags>