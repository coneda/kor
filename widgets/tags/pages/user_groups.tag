<kor-user-groups>
  <kor-help-button key="user_groups" />

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <a
        if={!opts.type}
        href="#/groups/user/new"
        class="pull-right"
        title={t('objects.new', {interpolations: {o: t('activerecord.models.user_group')}})}
      ><i class="plus"></i></a>
      <h1>
        <virtual if={!opts.type}>{tcap('activerecord.models.user_group', {count: 'other'})}</virtual>
        <virtual if={opts.type == 'shared'}>{tcap('nouns.shared_user_group')}</virtual>
      </h1>
      
      <kor-nothing-found data={data} />

      <table if={data && data.total > 0}>
        <thead>
          <th>{tcap('activerecord.attributes.user_group.name')}</th>
          <th if={opts.type == 'shared'}>{tcap('activerecord.attributes.user_group.owner')}</th>
          <th class="right"></th>
        </thead>
        <tbody if={data}>
          <tr each={user_group in data.records}>
            <td>
              <a href="#/groups/user/{user_group.id}">{user_group.name}</a>
            </td>
            <td if={opts.type == 'shared'}>
              {user_group.owner.display_name}
            </td>
            <td class="right">
              <virtual if={mine(user_group)}>
                <a
                  href="#/groups/user/{user_group.id}/edit"
                  title={t('verbs.edit')}
                ><i class="pen"></i></a>
                <a
                  href="#/groups/user/{user_group.id}/destroy"
                  onclick={onDeleteClicked}
                  title={t('verbs.delete')}
                ><i class="x"></i></a>
                <a
                  href="#/groups/user/{user_group.id}/share"
                  onclick={onShareClicked}
                  title={t('verbs.' + (user_group.shared ? 'unshare' : 'share'))}
                ><i class={private: !user_group.shared, public: user_group.shared}></i></a>
              </virtual>
            </td>
          </tr>
        </tbody>
      </table>

    </div>
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
      if (wApp.utils.confirm())
        destroy(event.item.user_group.id);
    }

    tag.onShareClicked = function(event) {
      event.preventDefault();
      var group = event.item.user_group;
      var verb = (group.shared ? 'unshare' : 'share');
      Zepto.ajax({
        type: 'PATCH',
        url: '/user_groups/' + group.id + '/' + verb,
        success: fetch
      })
    }

    tag.mine = function(group) {
      return group.user_id == tag.session().user.id
    }

    var destroy = function(id) {
      Zepto.ajax({
        type: 'DELETE',
        url: '/user_groups/' + id,
        success: fetch
      })
    }

    var fetch = function() {
      Zepto.ajax({
        url: (tag.opts.type == 'shared' ? '/user_groups/shared' : 'user_groups'),
        data: {include: 'owner'},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

  </script>

</kor-user-groups>