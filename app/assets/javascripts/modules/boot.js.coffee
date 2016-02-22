kor = angular.module('kor', ["ngRoute", "web-utils"])

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

kor.factory 'timeoutHttpIntercept', [
  '$rootScope', '$q',
  (rs, q) ->
    factory = {
      'request': (config) ->
        config.timeout = 10000
        config
    }
]

kor.config([ 
  "$httpProvider", "$sceProvider", "$routeProvider",
  (hp, sce, rp) ->
    sce.enabled(false)

    rp.when "/entities/gallery", templateUrl: ((params) -> "/tpl/entities/gallery"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/multi_upload", templateUrl: ((params) -> "/tpl/entities/multi_upload?#{Math.random()}"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/isolated", templateUrl: ((params) -> "/tpl/entities/isolated"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/:id", templateUrl: "/tpl/entities/1", reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/denied", templateUrl: ((params) -> "/tpl/denied"), reloadOnSearch: false

  ]
)

kor.run([ ->
  
])

this.kor = kor