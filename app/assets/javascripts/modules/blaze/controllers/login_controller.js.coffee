kor.controller "login_controller", [
  "$scope", "$location"
  (scope, l) ->
    scope.fragment = -> l.path()

]