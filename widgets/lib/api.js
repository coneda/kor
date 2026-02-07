import config from './config'

import {Url, Search as WendigSearch} from '@wendig/lib'

let rootUrl = ''

const drop = (object, key) => {
  const value = object[key]
  delete object[key]

  return value
}

export default class Api {
  constructor(info) {
    this.info = info
    this.rootUrl = info.url

    if (info.static) {
      this.worker = new WendigSearch(`${this.rootUrl}db.js`)
    }

    this.request = this.request.bind(this)
  }

  formatBody(data) {
    if (typeof data === 'string') return data
    if (data instanceof String) return data
    if (data instanceof FormData) return data

    return JSON.stringify(data)
  }

  http(url, init) {
    delete init['url']

    if (!url.startsWith('http')) url = `${this.rootUrl}${url}`

    wApp.state.requests.push([url, init])
    wApp.bus.trigger('ajax-state-changed')

    init['headers'] = init['headers'] || {}
    init['headers']['Accept'] = 'application/json'
    init['headers']['Content-Type'] = 'application/json'

    init['method'] = (init['type'] || 'GET').toUpperCase()

    if (['POST', 'PATCH', 'PUT', 'DELETE'].includes(init['method'])) {
      init['headers']['X-CSRF-Token'] = wApp.session.csrfToken()

      if (init['data']) {
        init['body'] = this.formatBody(init['data'])
        if (init['body'] instanceof FormData) delete init['headers']['Content-Type']
        delete init['data']
      }
    } else {
      if (init['data']) {
        const u = Url.parse(url)

        for (const [k, v] of Object.entries(init['data'])) {
          init['data'][k] = (
            (v === undefined || v === null) ?
            '' :
            encodeURIComponent(init['data'][k])
          )
        }

        u.updateParams(init['data'])
        url = u.url()

        delete init['data']
      }
    }

    return new Promise(async (resolve, reject) => {
      const response = await fetch(url, init)
      response.bodyStr = await response.text()

      const ct = response.headers.get('content-type')
      if (ct === 'application/json; charset=utf-8') {
        response.data = JSON.parse(response.bodyStr)

        if (response.status >= 200 && response.status < 300) {
          if (init['success']) init['success'](response.data)
          if (init['complete']) init['complete'](response)

          resolve(response)
        } else {
          if (init['error']) init['error'](response)
          if (init['complete']) init['complete'](response)

          reject(response)
        }
      } else {
        if (init['error']) init['error'](response)
        if (init['complete']) init['complete'](response)

        reject(response)
      }

      wApp.state.requests.pop()
      wApp.bus.trigger('ajax-state-changed')

      wApp.bus.trigger('request-complete', response)
    })
  }

  webWorker(url, opts) {
    const success = drop(opts, 'success')
    const error = drop(opts, 'error')
    const complete = drop(opts, 'complete')

    const promise = this.worker.postMessage({action: 'api', opts})

    if (success) promise.then(success)
    if (error) promise.catch(error)
    if (complete) promise.finally(complete)

    return promise
  }

  request(opts) {
    const url = opts['url']

    if (this.info.static) {
      return this.webWorker(url, opts)
    } else {
      return this.http(url, opts)
    }
  }
}
