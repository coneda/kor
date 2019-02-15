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
    Lockr.set('back-url', l.absUrl())
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
    hp.interceptors.push('addCsrf');

    sce.enabled(false)
    tpl = (id) -> $("script[type='text/x-kor-tpl'][data-id='#{id}']").html()

    rp.when "/relations/new", resolve: {tag: -> 'kor-relation-editor'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/relations/:id", resolve: {tag: -> 'kor-relation-editor'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/relations", resolve: {tag: -> 'kor-relations'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/kinds/new", resolve: {tag: -> 'kor-kind-editor'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/kinds/:id", resolve: {tag: -> 'kor-kind-editor'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/kinds", resolve: {tag: -> 'kor-kinds'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/entities/:id/edit", resolve: {tag: -> 'kor-entity-editor'}, controller: 'riot_controller', reloadOnSearch: false, template: load_template('riot-loader')
    rp.when "/entities/gallery", template: tpl('gallery'), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/multi_upload", templateUrl: ((params) -> "/tpl/entities/multi_upload?#{Math.random()}"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/isolated", template: tpl('isolated'), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/:id", template: tpl('entity-show'), reloadOnSearch: true, controller: "record_history_controller"
    rp.when "/denied", templateUrl: ((params) -> "/tpl/denied"), reloadOnSearch: false

  ]
)

this.kor = kor