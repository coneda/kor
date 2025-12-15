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
    var p = (this.resourceId() ? this.updateRequest() : this.createRequest());
    p.done(this.onSuccess);
    p.fail(this.onError);
    p.always(this.onComplete);
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
    var data = {};
    data[this.resource.singular] = this.formValues();

    return Zepto.ajax({
      type: 'PATCH',
      url: '/' + this.resource.plural + '/' + this.resourceId(),
      data: data
    });
  },
  onSuccess: function(data) {
    this.errors = {};
    wApp.routing.path('/' + this.resource.plural);
  },
  onError: function(xhr) {
    this.errors = JSON.parse(xhr.responseText).errors;
    wApp.utils.scrollToTop();
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
