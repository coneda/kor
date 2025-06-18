window.wApp = {
  bus: riot.observable(),
  mixins: {},
  state: {
    requests: []
  },
  setup: function () {
    // these require no ajax requests during setup
    wApp.clipboard.setup()
    wApp.entityHistory.setup()

    return Promise.all([
      wApp.session.setup(),
      wApp.config.setup(),
      wApp.i18n.setup(),
      wApp.info.setup()
    ])
  }
}

