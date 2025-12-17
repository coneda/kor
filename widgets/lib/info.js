import config from './config'

let instance = null

export default class Info {
  static setup() {
    // we use raw fetch here because the result tells us if ConedaKOR is in static mode
    // we also try to load a static file first
    const promise = new Promise(async resolve => {
      const staticResponse = await fetch(`/static/info.json`)
      if (staticResponse.ok) {
        const data = await staticResponse.json()
        instance = new Info(data.info)
      } else {
        const apiResponse = await fetch(`/info.json`)
        const data = await apiResponse.json()
        instance = new Info(data.info)
      }

      console.log('INFO loaded')
      resolve(instance)
    })

    return promise
  }

  static instance() {
    return instance
  }

  static mixins() {
    return {
      info: function () {
        return instance.data
      },
      rootUrl: function () {
        return this.info().url
      }
    }
  }

  constructor(data) {
    this.data = data
  }
}
