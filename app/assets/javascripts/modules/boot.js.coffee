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

load_template = (id) ->
  $("script[type='text/x-kor-tpl'][data-id='#{id}']").html()

kor.config([ 
  "$httpProvider", "$sceProvider", "$routeProvider",
  (hp, sce, rp) ->
    sce.enabled(false)
    tpl = (id) -> $("script[type='text/x-kor-tpl'][data-id='#{id}']").html()

    rp.when "/kinds", resolve: {tag: -> 'kor-kind-tree'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/entities/:id/edit", resolve: {tag: -> 'kor-entity-editor'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/entities/gallery", template: tpl('gallery'), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/multi_upload", templateUrl: ((params) -> "/tpl/entities/multi_upload?#{Math.random()}"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/isolated", template: tpl('isolated'), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/:id", template: tpl('entity-show'), reloadOnSearch: true, controller: "record_history_controller"
    rp.when "/denied", templateUrl: ((params) -> "/tpl/denied"), reloadOnSearch: false

  ]
)

this.kor = kor