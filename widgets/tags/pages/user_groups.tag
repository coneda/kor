<kor-user-groups>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <a href="#/groups/user/new" class="pull-right"><i class="plus"></i></a>
      <h1>{tcap('activerecord.models.user_group', {count: 'other'})}</h1>
      
      <table>
        <thead>
          <th>{tcap('activerecord.attributes.user_group.name')}</th>
          <th class="right"></th>
        </thead>
        <tbody if={data}>
          <tr each={user_group in data.records}>
            <td>{user_group.name}</td>
            <td class="right">
              <a href="#/groups/user/{user_group.id}/edit"><i class="pen"></i></a>
              <a
                href="#/groups/user/{user_group.id}/destroy"
                onclick={onDeleteClicked}
              ><i class="x"></i></a>
            </td>
          </tr>
        </tbody>
      </table>

    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    tag = this
    tag.mixin(wApp.mixins.config)
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on('mount', function() {
      fetch();
    })

    tag.onDeleteClicked = function(event) {
      event.preventDefault();
      if (wApp.utils.confirm())
        destroy(event.item.user_group.id);
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
        url: '/user_groups',
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }

  </script>

</kor-user-groups>