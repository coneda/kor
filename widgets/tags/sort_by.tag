<kor-sort-by>
  <a href="#" onclick={click}><yield />{directionIndicator()}</a>

  <script type="text/javascript">
    let tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.click = function(event) {
      event.preventDefault();

      var newQuery = {}

      if (currentPage()) {
        newQuery['page'] = 1;
      }

      if (currentSort() != tag.opts.key) {
        newQuery['sort'] = tag.opts.key;
        newQuery['direction'] = 'asc'
      } else {
        if (currentDirection() == 'asc') {
          newQuery['direction'] = 'desc';
        } else {
          newQuery['direction'] = 'asc';
        }
      }

      var fd = tag.opts.forceDirection
      if (fd) {
        newQuery['direction'] = fd
      }

      wApp.routing.query(newQuery);
    }

    tag.directionIndicator = function() {
      if (currentSort() == tag.opts.key) {
        if (currentDirection() == 'asc') {
          return ' ▴';
        } else {
          return ' ▾';
        }
      } else {
        return '';
      }
    }

    var currentSort = function() {
      return wApp.routing.query()['sort'];
    }

    var currentDirection = function() {
      var fd = tag.opts.forceDirection
      if (fd) return fd

      return wApp.routing.query()['direction'];
    }

    var currentPage = function() {
      return wApp.routing.query()['page'];
    }
  </script>
</kor-sort-by>