let instance = null

export default class Info {
  static setup() {
    // we use raw fetch here because the result tells us if ConedaKOR is in static mode
    // we also try to load a static file first
    const promise = new Promise(resolve => {
      fetch('/static/info.json').then(r => r.json()).then(data => {
        instance = new Info(data.info)
        console.log('INFO loaded')

        resolve(instance)
      }).catch(error => {
        fetch('/info.json').then(r => r.json()).then(data => {
          instance = new Info(data.info)
          console.log('INFO loaded')

          resolve(instance)
        })
      })
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
