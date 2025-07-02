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

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // Toggle the tag editor UI
  tag.toggleEditor = function(event) {
    if (event) event.preventDefault();
    tag.editorActive = !tag.editorActive;
  };

  // Save the updated tags via AJAX
  tag.save = function(event) {
    event.preventDefault();
    Zepto.ajax({
      type: 'PATCH',
      url: '/entities/' + tag.opts.entity.id + '/update_tags',
      data: JSON.stringify({ entity: { tags: tag.refs.field.value() } }),
      success: function(data) {
        tag.toggleEditor();
        tag.update();
        var h = tag.opts.handlers && tag.opts.handlers.doneHandler;
        if (h) h();
      }
    });
  };

  // Cancel editing tags
  tag.cancel = function(event) {
    event.preventDefault();
    tag.editorActive = false;
  };
</script>
</kor-inplace-tags>