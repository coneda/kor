import config from './config'
// import Article from './article'

import {Url, util, Search as WendigSearch} from '@wendig/lib'

// const clean = (params) => {
//   let result = {}

//   for (const [k, v] of Object.entries(params)) {
//     if (k === undefined || k === null) continue
//     if (v === undefined || v === null) continue

//     result[k] = params[k]
//   }

//   return result
// }

const request = (url, init = {}) => {
  url = `${Url.current().origin()}${url}`

  wApp.state.requests.push([url, init])
  wApp.bus.trigger('ajax-state-changed')

  init['headers'] = init['headers'] || {}
  init['headers']['Accept'] = 'application/json'
  init['headers']['Content-Type'] = 'application/json'

  init['method'] = (init['type'] || 'GET').toUpperCase()

  if (['POST', 'PATCH', 'PUT', 'DELETE'].includes(init['method'])) {
    init['headers']['X-CSRF-Token'] = wApp.session.csrfToken()

    if (init['data']) {
      init['body'] = (
        (typeof init['data'] === 'string' || init['data'] instanceof String) ?
        init['data'] :
        JSON.stringify(init['data'])
      )

      delete init['data']
    }
  } else {
    if (init['data']) {
      const u = Url.parse(url)

      for (const [k, v] of Object.entries(init['data'])) {
        init['data'][k] = (
          (v === undefined || v === null) ?
          '' :
          init['data'][k]
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

    // then(r => {
    //   if (!r.ok) {
    //     throw new Error(`http ${url}: status, ${r.status}`)
    //   }

    //   const p = r.json()

    //   if (init['success']) {
    //     p.then(init['success'])

    //     delete init['success']
    //   }

    //   return p
    // }).
    // finally(r => {
    //   wApp.state.requests.pop()
    //   wApp.bus.trigger('ajax-state-changed')
    // })
}

export default class Api extends WendigSearch {
  constructor() {
    const url = Url.current()

    super(`${url.origin()}/db.js`)
  }

  request(opts) {
    const url = opts['url']
    delete opts['url']

    // console.log('USING FETCH API', url, opts)

    return request(url, opts)

    // return this.postMessage({action: 'all', criteria}).then(data => {
    //   // data['results'] = data['results'].map(r => new Article(r))

    //   return data
    // })
  }
}

