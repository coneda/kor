kor = angular.module('kor', ["ngRoute"])

kor.controller "record_history_controller", [
  "$http", "$location",
  (http, l) ->
    http(
      method: 'post'
      url: "/tools/history"
      data: {url: l.absUrl()}
    )
]

kor.config([ 
  "$httpProvider", "$sceProvider", "$routeProvider",
  (hp, sce, rp) ->
    sce.enabled(false)

    hp.responseInterceptors.push [
      "$q", "korFlash",
      (q, korFlash) ->
        (promise) ->
          promise.then (response) ->
            if m = response.headers('X-Message-Error')
              korFlash.error = m

            if m = response.headers('X-Message-Notice')
              korFlash.notice = m

            response

    ]

    rp.when "/entities/multi_upload", templateUrl: ((params) -> "/tpl/entities/multi_upload"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/isolated", templateUrl: ((params) -> "/tpl/entities/isolated"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/entities/:id", templateUrl: ((params) -> "/tpl/entities/#{params.id}"), reloadOnSearch: false, controller: "record_history_controller"
    rp.when "/denied", templateUrl: ((params) -> "/tpl/denied"), reloadOnSearch: false

  ]
)

kor.run([ ->
  
])

this.kor = kor