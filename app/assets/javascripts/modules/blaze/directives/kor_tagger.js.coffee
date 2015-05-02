kor.directive "korTagger", [
  "$http",
  (http) ->
    split = (value) -> value.split(/,\s*/)
    extract_last = (term) -> split(term).pop()

    directive = {
      link: (scope, element) ->

        $(element).on "blur", (event) -> 
          input = $(event.currentTarget)
          input.val(input.val().replace(/,\s+$/, ''))

        $(element).autocomplete(
          source: (request, response) ->
            request = http(
              method: 'get'
              url: '/tags'
              params: {term: extract_last(request.term)}
            ).success(response)
            # $.getJSON('/tags', {term: Tagging.extract_last(request.term)}, response)
          search: ->
            term = extract_last(this.value)
            return false if term.length > 2
          focus: -> false
          select: (event, ui) ->
            terms = split(this.value)
            terms.pop()
            terms.push(ui.item.value)
            terms.push('')
            this.value = terms.join(", ")
            false
        )
    }
]

# Tagging.split = function(val) {
#   return val.split(/,\s*/);
# }

# Tagging.extract_last = function(term) {
#   return Tagging.split(term).pop();
# }

# Tagging.tagger = function(id) {
#   $('#' + id).blur(function(event) {
#     var input = $(this);
#     input.val(input.val().replace(/,\s+$/, ''));
#   });
#   $('#' + id).autocomplete({
#     source: function(request, response) {
#       $.getJSON('/tags', {term: Tagging.extract_last(request.term)}, response);
#     },
#     search: function() {
#       var term = Tagging.extract_last(this.value);
#       if (term.length > 2) {
#         return false;
#       }
#     },
#     focus: function() {
#       return false;
#     },
#     select: function(event, ui) {
#       var terms = Tagging.split(this.value);
#       terms.pop();
#       terms.push(ui.item.value);
#       terms.push('');
#       this.value = terms.join(", ")
#       return false;
#     }
#   });
# }
