<kor-generators>
  <div class="pull-right kor-text-right">
    <a
      href="#/kinds/{opts.kind.id}/edit/generators/new"
      title={t('verbs.add')}
    >
      <i class="fa fa-plus-square"></i>
    </a>
  </div>
  
  <strong>
    {tcap('activerecord.models.generator', {count: 'other'})}
  </strong>

  <div class="clearfix"></div>

  <ul if={opts.kind}>
    <li
      each={generator in opts.kind.generators}
      key={generator.id}
      data-id={generator.id}
    >
      <div class="pull-right kor-text-right">
        <a
          href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}/edit"
          title={t('verbs.edit')}
        ><i class="fa fa-edit"></i></a>
        <a
          href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}"
          onclick={remove(generator)}
          title={t('verbs.delete')}
        ><i class="fa fa-remove"></i></a>
        <a
          class="handle"
          href="#"
          onclick={preventDefault}
          title={t('change_order')}
        ><i class="fa fa-bars"></i></a>
      </div>
      <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}/edit">{generator.name}</a>
      <div class="clearfix"></div>
    </li>
  </ul>

  <div class="clearfix"></div>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);

  // On mount, enable sortable for the generator list
  tag.on('mount', function() {
    var ul = tag.root.querySelector('ul');
    new Sortable(ul, {
      draggable: 'li',
      handle: '.handle',
      forceFallback: true,
      onEnd: function(event) {
        if (event.newIndex !== event.oldIndex) {
          var id = event.item.getAttribute('data-id');
          var params = JSON.stringify({ generator: { position: event.newIndex } });
          Zepto.ajax({
            type: 'PATCH',
            url: '/kinds/' + tag.opts.kind.id + '/generators/' + id,
            data: params,
            success: function() {
              tag.opts.notify.trigger('refresh');
            }
          });
        }
      }
    });
  });

  // Remove a generator
  tag.remove = function(generator) {
    return function(event) {
      event.preventDefault();
      if (wApp.utils.confirm(wApp.i18n.translate('confirm.general'))) {
        Zepto.ajax({
          type: 'DELETE',
          url: '/kinds/' + tag.opts.kind.id + '/generators/' + generator.id,
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
</kor-generators>