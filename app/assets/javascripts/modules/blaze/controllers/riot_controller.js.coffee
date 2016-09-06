kor.controller 'riot_controller', [
  "$scope", "tag", "$routeParams",
  (scope, tag, rp) ->
    riot.mount $('.w-style')[0], 'w-style'
    riot.mount $('.riot-content')[0], tag, rp
]