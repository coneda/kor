<kor-credential-editor>
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1 if={opts.id}>
        {tcap('objects.edit', {interpolations: {o: 'activerecord.models.credential'}})}
      </h1>
      <h1 if={!opts.id}>
        {tcap('objects.create', {interpolations: {o: 'activerecord.models.credential'}})}
      </h1>

      <form onsubmit={submit} if={data}>
        <kor-input
          label={tcap('activerecord.attributes.credential.name')}
          name="name"
          ref="fields"
          value={data.name}
          errors={errors.name}
        />

        <kor-input
          label={tcap('activerecord.attributes.credential.description')}
          name="description"
          type="textarea"
          ref="fields"
          value={data.description}
          errors={errors.description}
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
  tag.mixin(wApp.mixins.page)

  // Initialize errors and data before mounting the tag
  tag.on('before-mount', function() {
    tag.errors = {}
    tag.data = {}
  })

  // On mount, fetch data if editing an existing credential
  tag.on('mount', function() {
    if (tag.opts.id) {
      fetch()
    }
  })

  // Handle form submission for creating or updating a credential
  tag.submit = function(event) {
    event.preventDefault()
    var p = tag.opts.id ? update() : create()
    p.done(function(data) {
      tag.errors = {}
      window.history.back()
    })
    p.fail(function(xhr) {
      tag.errors = JSON.parse(xhr.responseText).errors
      wApp.utils.scrollToTop()
    })
    p.always(function() {
      tag.update()
    })
  }

  // Fetch credential data from the server
  var fetch = function() {
    Zepto.ajax({
      url: '/credentials/' + tag.opts.id,
      success: function(data) {
        tag.data = data
        tag.update()
      }
    })
  }

  // Create a new credential
  var create = function() {
    return Zepto.ajax({
      type: 'POST',
      url: '/credentials',
      data: JSON.stringify({ credential: values() })
    })
  }

  // Update an existing credential
  var update = function() {
    return Zepto.ajax({
      type: 'PATCH',
      url: '/credentials/' + tag.opts.id,
      data: JSON.stringify({ credential: values() })
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
</script>
</kor-credential-editor>
