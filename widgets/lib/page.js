wApp.mixins.page = {
  title: function(newTitle) {
    wApp.bus.trigger(
      'page-title',
      wApp.utils.capitalize(newTitle)
    );
  }
}
