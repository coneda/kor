kor.controller "login_controller", [
  "$scope", "$location"
  (scope, l) ->
    window.l = l
    scope.fragment = -> l.path()

]