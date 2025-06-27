<kor-admin-group-category-editor>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.authority_group_category'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.authority_group_category'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.authority_group.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <kor-input
          if={categories}
          label={tcap('activerecord.models.authority_group_category')}
          name="parent_id"
          type="select"
          options={categories}
          placeholder=""
          ref="fields"
          value={data.parent_id || opts.parentId}
          errors={errors.parent_id}
        />

        <div class="hr"></div>

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  var tag = this
  tag.mixin(wApp.mixins.sessionAware)
  tag.mixin(wApp.mixins.i18n)
  tag.mixin(wApp.mixins.auth)
  tag.mixin(wApp.mixins.page)

  // Before mounting, fetch categories and check admin permission
  tag.on('before-mount', function() {
    fetchCategories()
    tag.errors = {}
    tag.data = {}

    if (!tag.isAuthorityGroupAdmin()) {
      wApp.bus.trigger('access-denied')
    }
  })

  // On mount, fetch category data if editing
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch()
    }
  })

  // Handle form submission for create or update
  tag.submit = function(event) {
    event.preventDefault()
    var p = tag.opts.id ? update() : create()
    p.done(function(data) {
      tag.errors = {}
      var id = values()['parent_id']
      if (id) {
        wApp.routing.path('/groups/categories/' + id)
      } else {
        wApp.routing.path('/groups/categories')
      }
    })
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors
      wApp.utils.scrollToTop()
    })
    p.always(function() {
      tag.update()
    })
  }

  // Fetch authority group category data from server
  var fetch = function() {
    Zepto.ajax({
      url: '/authority_group_categories/' + tag.opts.id,
      success: function(data) {
        tag.data = data
        tag.update()
      }
    })
  }

  // Fetch all authority group categories for select options
  var fetchCategories = function() {
    Zepto.ajax({
      url: '/authority_group_categories/flat',
      data: { include: 'ancestors' },
      success: function(data) {
        var results = [{ value: '0', label: tag.t('none') }]
        for (var i = 0; i < data.records.length; i++) {
          var r = data.records[i]
          if (r.id != tag.opts.id) {
            var names = []
            for (var j = 0; j < r.ancestors.length; j++) {
              names.push(r.ancestors[j].name)
            }
            names.push(r.name)
            results.push({
              value: r.id,
              label: names.join(' » ')
            })
          }
        }
        tag.categories = results
        tag.update()
      }
    })
  }

  // Create a new authority group category
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: '/authority_group_categories',
      data: JSON.stringify({ authority_group_category: values() })
    })
  }

  // Update an existing authority group category
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: '/authority_group_categories/' + tag.opts.id,
      data: JSON.stringify({ authority_group_category: values() })
    })
  }

  // Collect form values for submission
  var values = function() {
    var results = {}
    var fields = wApp.utils.toArray(tag.refs.fields)
    for (var i = 0; i < fields.length; i++) {
      var f = fields[i]
      results[f.name()] = f.value()
    }
    return results
  }
</script>
</kor-admin-group-category-editor>
