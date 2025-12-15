wApp.routing = {
  query(params, reset = false) {
    if (params) {
      const result = {}
      const base = reset ? {} : wApp.routing.query()
      Object.assign(result, base, params)
      const qs = [];
      for (const [k, v] of Object.entries(result)) {
        if (result[k] != null && result[k] !== '') {
          qs.push(`${k}=${v}`)
        }
      }

      route(`${wApp.routing.path()}?${qs.join('&')}`)
    } else {
      const result = wApp.routing.parts().hash_query || {}
      return Object.assign({}, result)
    }
  },
  path(new_path) {
    if (new_path) {
      route(new_path)
    } else {
      return wApp.routing.parts().hash_path
    }
  },
  fragment() {
    return window.location.hash
  },
  back() {
    window.history.back();
  },
  parts() {
    if (!wApp.routing.parts_cache) {
      const h = window.location.href
      const cs = h.match(/^(https?):\/\/([^\/]+)([^?#]+)?(?:\?([^#]+))?(?:#(.*))?$/)
      const result = {
        href: h,
        scheme: cs[1],
        host: cs[2],
        path: cs[3],
        query_string: cs[4],
        query: {},
        hash: cs[5],
        hash_query: {},
      };
      if (result.query_string) {
        for (const pair of result.query_string.split('&')) {
          const kv = pair.split('=')
          result.query[kv[0]] = kv[1]
        }
      }
      if (result.hash) {
        result.hash_path = result.hash.split('?')[0]
        const hash_query_string = result.hash.split('?')[1]
        if (hash_query_string) {
          for (const pair of hash_query_string.split('&')) {
            const kv = pair.split('=')
            result.hash_query[kv[0]] = decodeURIComponent(kv[1])
          }
        }
      }
      wApp.routing.parts_cache = result;
    }

    return wApp.routing.parts_cache;
  },
  setup() {
    wApp.routing.route = route.create();
    route.base("#/");

    wApp.routing.route(() => {
      const old_parts = wApp.routing.parts();
      if (window.location.href !== old_parts.href) {
        wApp.routing.parts_cache = null;
        wApp.bus.trigger('routing:href', wApp.routing.parts())

        if (old_parts.hash_path !== wApp.routing.path()) {
          wApp.bus.trigger('routing:path', wApp.routing.parts())
        } else {
          wApp.bus.trigger('routing:query', wApp.routing.parts())
        }
      }
    });
    route.start(true);
    wApp.bus.trigger('routing:path', wApp.routing.parts())
  },
  tearDown() {
    if (wApp.routing.route) {
      wApp.routing.route.stop()
    }
  }
}
