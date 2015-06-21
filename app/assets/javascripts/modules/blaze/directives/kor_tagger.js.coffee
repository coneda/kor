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
