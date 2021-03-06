wApp.mixins.form = {
  values: function() {
    var results = {};
    var fields = this.fields();
    for (var i = 0; i < fields.length; i++) {
      var f = fields[i];
      var v = f.value();

      if (v === '' || v === [] || v === undefined) {
        results[f.name()] = null;
      } else {
        results[f.name()] = v;
      }
    }
    return results;
  },
  setValues: function(values, clean) {
    var fields = this.fields();
    for (var i = 0; i < fields.length; i++) {
      var f = fields[i];
      var v = values[f.name()];
      if (v) {
        if (!f.set) {console.log(f)}
        f.set(v);
      }

      if (!v && !!clean) {
        f.reset();
      }
    }
  },
  fields: function() {
    // TODO: apply this to all forms!
    var byTag = wApp.utils.toArray(this.tags['kor-input']).
      filter(function(i){return i.opts.type != 'submit' && i.opts.type != 'reset'});
    var byRef = wApp.utils.toArray(this.refs['fields']);
    return byTag.concat(byRef);
  },
  fieldsByName: function() {
    var results = {};
    var fields = this.fields();
    for (var i = 0; i < fields.length; i++) {
      f = fields[i];
      results[f.name()] = f;
    }
    return results;
  }
}
