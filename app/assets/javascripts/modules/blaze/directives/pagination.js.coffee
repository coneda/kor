kor.directive "korPagination", [
  "$location", "$routeParams",
  (l, rp) ->
    directive = {
      templateUrl: "/tpl/pagination"
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

        window.l = l
        scope.page_model = if scope.use_search
          search_value = l.search()['page']
          if search_value
            sanitize(search_value)
          else
            #l.search('page', 1).notify(false)
            1
        else
          1

        # scope.new_page ||= 1
        # scope.new_page = if scope.use_search
        #   console.log rp.page
        #   parseInt(rp.page) || 1
        # else
        #   1

        # scope.$on '$routeUpdate', -> scope.new_page = rp.page || 1

        scope.update = (new_page, event) ->
          if new_page
            scope.page_model = sanitize(new_page)

          # if scope.page_model > scope.total_pages()
          #   scope.page_model = scope.total_pages()
          # if scope.page_model < 1
          #   scope.page_model = 1

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
        # parse_int = (value) ->
        #   result = parseInt(value)
        #   if isNaN(result) then 1 else result
        # boxed_page = (value) ->
        #   result = Math.max(1, value)
        #   Math.min(scope.total_pages(), value)
        # sanitize = (value) -> boxed_page(parse_int(value))
        # scope.total_pages = -> Math.ceil(scope.total / scope.per_page)

        # if scope.use_search
        #   scope.page_model_model = sanitize(l.search 'page')
        #   scope.$on '$routeUpdate', ->
        #     new_value = sanitize(l.search 'page')
        #     scope.page_model_model = new_value
        #     notify_owner(new_value)
        #   scope.goto_page = (new_page, event) ->
        #     event.preventDefault() if event
        #     l.search page: sanitize(new_page)
        # else
        #   scope.page_model_model = 1
        #   scope.goto_page = (new_page, event) ->
        #     event.preventDefault() if event
        #     new_value = sanitize(new_page)
        #     scope.page_model_model = new_value
        #     notify_owner(new_value)

        # notify_owner = (new_page) -> scope.page_model = new_page

        # scope.input_handler = (value) ->
        #   if value == null
        #     sanitize(scope.input_model)
        #   else
        #     scope.input_model = sanitize(value)

        # scope.$watch 'input_model', (new_value) -> scope.goto_page(new_value)

        # $(element).on "click", "input[type=number]", (event) -> $(event.target).select()

    } 
]