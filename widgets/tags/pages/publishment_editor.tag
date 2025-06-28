<kor-publishment-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.publishment'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.publishment'}})}
      </h1>

      <form onsubmit={submit}>
        <kor-input
          label={tcap('activerecord.attributes.publishment.name')}
          name="name"
          ref="fields"
          errors={errors.name}
          autofocus={true}
        />

        <kor-input
          if={userGroups}
          label={tcap('activerecord.models.user_group')}
          name="user_group_id"
          type="select"
          options={userGroups}
          ref="fields"
          errors={errors.user_group}
        />

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this
  tag.mixin(wApp.mixins.sessionAware)
  tag.mixin(wApp.mixins.i18n)
  tag.mixin(wApp.mixins.page)

  // Before mounting, fetch user groups and initialize data/errors
  tag.on('before-mount', function() {
    fetchGroups()
    tag.data = {}
    tag.errors = {}
  })

  // Handle form submission for creating a publishment
  tag.submit = function(event) {
    event.preventDefault()
    var p = create()
    p.done(function(data) {
      tag.errors = {}
      var id = tag.opts.id || data.id
      wApp.routing.path('/groups/published')
    })
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors
      wApp.utils.scrollToTop()
    })
    p.always(function() {
      tag.update()
    })
  }

  // Create a new publishment
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: '/publishments',
      data: JSON.stringify({ publishment: values() })
    })
  }

  // Collect form values for submission
  var values = function() {
    var results = {}
    for (var i = 0; i < tag.refs.fields.length; i++) {
      var f = tag.refs.fields[i]
      results[f.name()] = f.value()
    }
    return results
  }

  // Fetch user groups for select options
  var fetchGroups = function() {
    Zepto.ajax({
      url: '/user_groups',
      success: function(data) {
        tag.userGroups = []
        for (var i = 0; i < data.records.length; i++) {
          var record = data.records[i]
          tag.userGroups.push({ value: record.id, label: record.name })
        }
        tag.update()
      }
        })
  }
</script>
</kor-publishment-editor>
