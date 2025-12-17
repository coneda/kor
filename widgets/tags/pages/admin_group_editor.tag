<kor-admin-group-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box" >
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.authority_group'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.authority_group'}})}
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
          name="authority_group_category_id"
          type="select"
          options={categories}
          placeholder=""
          ref="fields"
          value={data.authority_group_category_id}
          errors={errors.authority_group_category_id}
        />

        <div class="hr"></div>

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  let tag = this
  tag.mixin(wApp.mixins.sessionAware)
  tag.mixin(wApp.mixins.i18n)
  tag.mixin(wApp.mixins.auth)
  tag.mixin(wApp.mixins.page)

  // Before mounting, check admin permission and fetch categories
  tag.on('before-mount', function(e) {
    tag.errors = {}
    fetchCategories()

    if (!tag.isAuthorityGroupAdmin()) {
      wApp.bus.trigger('access-denied')
      // Prevent the tag from mounting
      throw 'access denied'
    }
  })

  // On mount, fetch group data if editing, otherwise initialize data
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch()
    } else {
      tag.data = {}
      tag.data.authority_group_category_id = tag.opts.categoryId
    }
  })

  // Handle form submission for create or update
  tag.submit = function(event) {
    event.preventDefault()
    var p = tag.opts.id ? update() : create()
    p.then(function(response) {
      tag.errors = {}
      var id = values()['authority_group_category_id']
      if (id && id != '-1') {
        wApp.routing.path('/groups/categories/' + id)
      } else {
        wApp.routing.path('/groups/categories')
      }
    })
    p.catch(response => {
      tag.errors = response.data.errors
      wApp.utils.scrollToTop()
    })
    p.finally(function() {
      tag.update()
    })
  }

  // Fetch authority group categories from server
  var fetchCategories = function() {
    Zepto.ajax({
      url: '/authority_group_categories/flat',
      data: { include: 'ancestors' },
      success: function(data) {
        var results = [{ value: -1, label: tag.t('none') }]
        for (var i = 0; i < data.records.length; i++) {
          var r = data.records[i]
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
        tag.categories = results
        tag.update()
      }
    })
  }

  // Fetch authority group data from server
  var fetch = function() {
    Zepto.ajax({
      url: '/authority_groups/' + tag.opts.id,
      success: function(data) {
        tag.data = data
        tag.update()
      }
    })
  }

  // Create a new authority group
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: '/authority_groups',
      data: JSON.stringify({ authority_group: values() })
    })
  }

  // Update an existing authority group
  var update = function() {
    console.log(values())
    return Zepto.ajax({
      type: 'PATCH',
      url: '/authority_groups/' + tag.opts.id,
      data: JSON.stringify({ authority_group: values() })
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
</kor-admin-group-editor>
