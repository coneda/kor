import Api from './lib/api'
import Config from './lib/config'
import Info from './lib/info'

window.wApp = {
  bus: riot.observable(),
  mixins: {
    info: Info.mixins(),
    config: Config.mixins()
  },
  state: {
    requests: []
  },
  setup: function () {
    // these require no ajax requests during setup
    wApp.clipboard.setup()
    wApp.entityHistory.setup()

    return new Promise((resolve) => {
      // first do the info request to know if we are in static mode
      Info.setup().then(() => {
        wApp.info = Info.instance()

        // now hook up the request fork
        if (wApp.info.data.static) {
          const api = new Api()
          wApp.api = api
          Zepto.ajax = api.request
        }

        // continue with the rest of the init code

        const cp = Config.setup().then(() => {
          wApp.config = Config.instance()
          wApp.bus.on('config-updated', wApp.config.refresh)
        })

        const all = Promise.all([
          cp,
          wApp.session.setup(),
          wApp.i18n.setup()
        ])

        all.then(resolve)
      })
    })
  }
}