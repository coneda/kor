<kor-fields>

  <div class="pull-right kor-text-right">
    <a
      href="#/kinds/{opts.kind.id}/edit/fields/new"
      title={t('verbs.add')}
    >
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    {tcap('activerecord.models.field', {count: 'other'})}
  </strong>

  <div class="clearfix"></div>

  <ul if={opts.kind}>
    <li each={field in opts.kind.fields} key={field.id} data-id={field.id}>
      <div class="pull-right kor-text-right">
        <a
          href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit"
          title={t('verbs.edit')}
        ><i class="fa fa-edit"></i></a>
        <a
          href="#"
          onclick={remove(field)}
          title={t('verbs.delete')}
        ><i class="fa fa-remove"></i></a>
        <a
          class="handle"
          href="#"
          onclick={preventDefault}
          title={t('change_order')}
        ><i class="fa fa-bars"></i></a>
      </div>
      <a
        href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit"
        title={field.show_label}
      >
        {wApp.utils.shorten(field.name, 20)}
      </a>
      <div class="clearfix"></div>
    </li>
  </ul>

  <div class="clearfix"></div>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // On mount, enable sortable for the fields list
  tag.on('mount', function() {
    var ul = tag.root.querySelector('ul');
    new Sortable(ul, {
      draggable: 'li',
      handle: '.handle',
      forceFallback: true,
      onEnd: function(event) {
        if (event.newIndex !== event.oldIndex) {
          var id = event.item.getAttribute('data-id');
          var params = JSON.stringify({ field: { position: event.newIndex } });
          Zepto.ajax({
            type: 'PATCH',
            url: '/kinds/' + tag.opts.kind.id + '/fields/' + id,
            data: params,
            success: function() {
              tag.opts.notify.trigger('refresh');
            }
          });
        }
      }
    });
  });

  // Remove a field
  tag.remove = function(field) {
    return function(event) {
      event.preventDefault();
      if (wApp.utils.confirm(wApp.i18n.translate('confirm.general'))) {
        Zepto.ajax({
          type: 'DELETE',
          url: '/kinds/' + tag.opts.kind.id + '/fields/' + field.id,
          success: function() {
            route('/kinds/' + tag.opts.kind.id + '/edit');
            tag.opts.notify.trigger('refresh');
          }
        });
      }
    };
  };

  // Prevent default event action
  tag.preventDefault = function(event) {
    event.preventDefault();
  };
</script>
</kor-fields>