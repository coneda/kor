kor.controller "multi_upload_controller", [
  "$scope", "korData", "$route",
  (scope, kd, r) ->
    scope.$on 'current-changed', -> r.reload()

    sh = ->
      text = kd.info.config.help['entities']['multi_upload'][kd.info.locale]
      if text && text != ''
        jQuery('#help').html(text)
        Kor.setup_help()

    if kd.info
      sh()
    else
      scope.$on 'kor-session-load-complete', sh
]