kor.controller 'riot_controller', [
  "$scope", "tag", "$routeParams",
  (scope, tag, rp) ->
    riot.mount $('.w-style')[0], 'w-style'
    riot.mount $('.w-modal')[0], 'w-modal'
    riot.mount $('.w-messaging')[0], 'w-messaging'
    riot.mount $('.riot-content')[0], tag, rp
]