kor = angular.module('kor', ["ngRoute", "web-utils"])

kor.factory 'addCsrf', ->
  return {
    request: (config) ->
      token = $("meta[name='csrf-token']").attr('content')
      if token
        config.headers['X-CSRF-Token'] = token
      config
  }

kor.controller "record_history_controller", [
  "$http", "$location", "session_service",
  (http, l, ss) ->
    ss.reset_flash()
    ss.read_legacy_flash()
    http(
      method: 'post'
      url: "/tools/history"
      data: {url: l.absUrl()}
    )
]

kor.config([ 
  "$httpProvider", "$sceProvider", "$routeProvider",
  (hp, sce, rp) ->
    hp.interceptors.push('addCsrf');

    sce.enabled(false)
    tpl = (id) -> $("script[type='text/x-kor-tpl'][data-id='#{id}']").html()

    rp.when "/entities/gallery", template: tpl('gallery'), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/multi_upload", templateUrl: ((params) -> "/tpl/entities/multi_upload?#{Math.random()}"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/isolated", template: tpl('isolated'), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/:id", template: tpl('entity-show'), reloadOnSearch: true, controller: "record_history_controller"
    rp.when "/denied", templateUrl: ((params) -> "/tpl/denied"), reloadOnSearch: false

  ]
)

kor.run([ ->
  
])

this.kor = kor