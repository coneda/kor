var Tagging = new Object();

Tagging.split = function(val) {
  return val.split(/,\s*/);
}

Tagging.extract_last = function(term) {
  return Tagging.split(term).pop();
}

Tagging.tagger = function(id) {
  $('#' + id).blur(function(event) {
    var input = $(this);
    input.val(input.val().replace(/,\s+$/, ''));
  });
  $('#' + id).autocomplete({
    source: function(request, response) {
      $.getJSON('/tags', {term: Tagging.extract_last(request.term)}, response);
    },
    search: function() {
      var term = Tagging.extract_last(this.value);
      if (term.length > 2) {
        return false;
      }
    },
    focus: function() {
      return false;
    },
    select: function(event, ui) {
      var terms = Tagging.split(this.value);
      terms.pop();
      terms.push(ui.item.value);
      terms.push('');
      this.value = terms.join(", ")
      return false;
    }
  });
}
