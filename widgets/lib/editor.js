wApp.mixins.editor = {
  resource: {
    singular: 'unknown-resource',
    plural: 'unknown-resources'
  },

  resourceId: function() {
    return tag.opts.id;
  },

  save: function(event) {
    event.preventDefault();
    var p = (this.resourceId() ? this.updateRequest() : this.createRequest())
    p.then(this.onSuccess)
    p.catch(this.onError)
    p.finally(this.onComplete)
  },

  createRequest: function() {
    var data = {};
    data[this.resource.singular] = this.formValues();

    return Zepto.ajax({
      type: 'POST',
      url: '/' + this.resource.plural,
      data: data
    });
  },

  updateRequest: function() {
    var data = {}
    data[this.resource.singular] = this.formValues()

    return Zepto.ajax({
      type: 'PATCH',
      url: '/' + this.resource.plural + '/' + this.resourceId(),
      data: data
    });
  },

  onSuccess: function(data) {
    this.errors = {}
    wApp.routing.path('/' + this.resource.plural)
  },

  onError: function(response) {
    this.errors = response.data.errors
    wApp.utils.scrollToTop()
  },

  onComplete: function() {
    this.update();
  },

  formValues: function() {
    var results = {};
    for (var i = 0; i < this.refs.fields.length; i++) {
      var f = this.refs.fields[i];
      results[f.name()] = f.value();
    }
    return results;
  }
};
