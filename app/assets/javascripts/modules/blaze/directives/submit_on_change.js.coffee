kor.directive 'korSubmitOnChange', [
  ->
    directive = {
      link: (scope, element, attrs) ->
        $(element).on 'change', -> $(element).parents('form').submit()
    }
]
