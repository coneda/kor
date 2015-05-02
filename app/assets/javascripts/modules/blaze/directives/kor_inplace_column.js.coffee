kor.directive "korInplaceColumn", [
  "$http",
  (http) ->
    split = (value) -> val.split(/,\s*/)
    extract_last = (term) -> split(term).pop()

    directive = {
      scope: {
        "data": "=korInplaceColumn"
        "url": "@korInplaceUrl"
      }
      link: (scope, element, attrs) ->
        edit_pane = $(element).find(".kor-inplace-edit")
        input = edit_pane.find("input")
        show_pane = $(element).find(".kor-inplace-show")
        control = $(element).find(".kor-inplace-control")

        edit_pane.hide()

        scope.$watch "editing", (new_value) ->
          if new_value
            edit_pane.show()
            show_pane.hide()
            input.val(null)
            input.focus()
          else
            edit_pane.hide()
            show_pane.show()

        control.on "click", (event) ->
          event.preventDefault()
          scope.editing = !scope.editing
          scope.$apply()

        input.on "blur", (event) ->
          http(
            method: "post"
            url: scope.url
            data: {value: input.val()}
            accept: "application/json"
          ).success((data)-> scope.data = data)
          scope.editing = false
          scope.$apply()

    }
]