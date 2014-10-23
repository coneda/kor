kor = angular.module('kor', ["ngRoute"])

kor.config([ 
  "$httpProvider", "$sceProvider",
  (httpProvider, sp) ->
    sp.enabled(false)

    httpProvider.responseInterceptors.push [
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

  ]
)

kor.run([ ->
  
])

this.kor = kor