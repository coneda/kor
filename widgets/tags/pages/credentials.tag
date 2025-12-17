<kor-credentials>

  <div class="kor-content-box">
    <a
      href="#/credentials/new"
      class="pull-right"
      title={t('objects.new', {interpolations: {o: t('activerecord.models.credential')}})}
    ><i class="fa fa-plus-square"></i></a>
    <h1>{tcap('activerecord.models.credential', {count: 'other'})}</h1>

    <table>
      <thead>
        <th>{tcap('activerecord.attributes.credential.name')}</th>
        <th class="right"># {tcap('activerecord.attributes.credential.user_count')}</th>
        <th class="right"></th>
      </thead>
      <tbody if={data}>
        <tr each={credential in data.records}>
          <td>
            <strong>{credential.name}</strong>
            <div if={credential.description}>{credential.description}</div>
          </td>
          <td class="right">{credential.user_count}</td>
          <td class="right">
            <a
              href="#/credentials/{credential.id}/edit"
              title={t('verbs.edit')}
            ><i class="fa fa-pencil"></i></a>
            <a
              href="#/credentials/{credential.id}/destroy"
              onclick={onDeleteClicked}
              title={t('verbs.delete')}
            ><i class="fa fa-trash"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <script type="text/javascript">
    let tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      tag.title(tag.t('activerecord.models.credential', {count: 'other'}))
      if (!tag.isAdmin()) {
        wApp.bus.trigger('access-denied')
        return;
      }

      fetch()
    })

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      if (wApp.utils.confirm())
        destroy(event.item.credential.id);
    }

    const destroy = function(id) {
      const p = Zepto.ajax({
        type: 'DELETE',
        url: '/credentials/' + id
      })
      p.then(response => fetch())
      p.catch(response => {
        tag.errors = response.data.errors
        wApp.utils.scrollToTop()
      })
    }

    const fetch = function() {
      Zepto.ajax({
        url: '/credentials',
        data: {include: 'counts'},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>
</kor-credentials>