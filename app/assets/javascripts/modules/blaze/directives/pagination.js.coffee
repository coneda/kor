kor.directive "korPagination", [
  "$location", "$routeParams", 'templates_service',
  (l, rp, ts) ->
    directive = {
      template: -> ts.get('pagination')
      replace: true
      scope: {
        page: "=korPagination"
        total: "=korTotal"
        per_page: "=korPerPage"
        use_search: "=korUseSearch"
      }
      link: (scope, element, attrs) ->
        parse_int = (value) ->
          result = parseInt(value)
          if isNaN(result) then 1 else result
        boxed_page = (value) ->
          result = Math.max(1, value)
          Math.min(scope.total_pages(), value)
        sanitize = (value) -> boxed_page(parse_int(value))
        scope.total_pages = -> Math.ceil(scope.total / scope.per_page)

        scope.$watch "page_model", (new_value) -> 
          if new_value
            scope.update()

        scope.page_model = if scope.use_search
          search_value = l.search()['page']
          if search_value
            sanitize(search_value)
          else
            1
        else
          1

        scope.update = (new_page, event) ->
          if new_page
            scope.page_model = sanitize(new_page)

          scope.page = scope.page_model
          if scope.use_search
            search_value = l.search()['page']
            if scope.page_model != 1 || search_value
              l.search('page', scope.page_model)

          event.preventDefault() if event

        $(element).on "click", "input[type=number]", (event) -> $(event.target).select()

        scope.page_input_handler = (value = null) ->
          if value == null
            parseInt(scope.page_model)
          else
            scope.page_model = parseInt(value)

    } 
]