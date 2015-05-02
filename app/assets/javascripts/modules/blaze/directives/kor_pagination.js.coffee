kor.directive "korPagination", [
  "$location", "$routeParams",
  (l, rp) ->
    directive = {
      templateUrl: "/tpl/pagination"
      replace: true
      scope: {
        "data": "=korPagination"
      }
      link: (scope, element, attrs) ->
        scope.new_page = rp.page || 1
        scope.$on '$routeUpdate', -> scope.new_page = rp.page || 1

        scope.update = (new_page, event) -> 
          l.search(page: new_page)
          event.preventDefault() if event
    } 
]