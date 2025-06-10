wApp.info = {
  setup: function () {
    return Zepto.ajax({
      url: '/info',
      success: function (data) {
        wApp.info.data = data.info
      }
    })
  }
}

wApp.mixins.info = {
  info: function () {
    return wApp.info.data
  },
  rootUrl: function () {
    return this.info().url
  }
}

