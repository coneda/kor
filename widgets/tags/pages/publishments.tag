<kor-publishments>

  <div class="kor-content-box">
    <a
      href="#/groups/published/new"
      class="pull-right"
      title={t('objects.new', {interpolations: {o: t('activerecord.models.publishment')}})}
    ><i class="plus"></i></a>
    <h1>{tcap('activerecord.models.publishment', {count: 'other'})}</h1>

    <kor-nothing-found data={data} type="entity" />
    
    <table if={data && data.total > 0}>
      <thead>
        <th>{tcap('activerecord.attributes.publishment.name')}</th>
        <th>{tcap('activerecord.attributes.publishment.link')}</th>
        <th>{tcap('activerecord.attributes.publishment.valid_until')}</th>
        <th class="right"></th>
      </thead>
      <tbody if={data}>
        <tr each={publishment in data.records}>
          <td>{publishment.name}</td>
          <td>
            <a
              href="{wApp.info.data.url}#{publishment.link}"
              target="_blank"
            >
              {wApp.info.data.url}#{publishment.link}
            </a>
          </td>
          <td>{l(publishment.valid_until, 'time.formats.default')}</td>
          <td class="right">
            <a
              href="#"
              title={t('verbs.extend')}
              onclick={onExtendClicked}
            ><i class="stop_watch"></i></a>
            <a
              href="#/groups/user/{user_group_id}/destroy"
              onclick={onDeleteClicked}
              title={t('verbs.delete')}
            ><i class="x"></i></a>
          </td>
        </tr>
      </tbody>
    </table>

  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
    })

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      var publishment = event.item.publishment;
      if (wApp.utils.confirm())
        destroy(publishment.id);
    }

    tag.onExtendClicked = function(event) {
      event.preventDefault();
      var publishment = event.item.publishment;
      Zepto.ajax({
        type: 'PATCH',
        url: '/publishments/' + publishment.id + '/extend',
        success: fetch
      })
    }

    var destroy = function(id) {
      Zepto.ajax({
        type: 'DELETE',
        url: '/publishments/' + id,
        success: fetch
      })
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/publishments',
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

  </script>

</kor-publishments>