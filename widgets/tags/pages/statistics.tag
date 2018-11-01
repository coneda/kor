<kor-statistics>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1>{tcap('nouns.statistics')}</h1>

      <p if={data}>{validity()}</p>

      <table if={data}>
        <thead>
          <tr>
            <th>{tcap('activerecord.models.user', {count: 'other'})}</th>
            <th>{data.user_count}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{tcap('logged_in_recently')}</td>
            <td>{data.user_count_logged_in_recently}</td>
          </tr>
          <tr>
            <td>{tcap('logged_in_last_year')}</td>
            <td>{data.user_count_logged_in_last_year}</td>
          </tr>
          <tr>
            <td>{tcap('created_recently')}</td>
            <td>{data.user_count_created_recently}</td>
          </tr>
        </tbody>
      </table>

      <table if={data}>
        <thead>
          <tr>
            <th>{tcap('activerecord.models.entity', {count: 'other'})}</th>
            <th>{data.entity_count}</th>
          </tr>
        </thead>
        <tbody>
          <tr each={stat in data.entities_by_kind}>
            <td>{stat.kind_name}</td>
            <td>{stat.count}</td>
          </tr>
        </tbody>
      </table>

      <table if={data}>
        <thead>
          <tr>
            <th>{tcap('activerecord.models.relationship', {count: 'other'})}</th>
            <th>{data.relationship_count}</th>
          </tr>
        </thead>
        <tbody>
          <tr each={stat in data.relationships_by_relation}>
            <td>{stat.relation_name}</td>
            <td>{stat.count}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="kor-layout-right"></div>
  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
    })

    tag.validity = function() {
      return tag.t('messages.statistics_validity', {
        interpolations: {
          date: tag.l(tag.data.timestamp, 'time.formats.exact')
        }
      })
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/statistics',
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      });
    }
  </script>

</kor-statistics>