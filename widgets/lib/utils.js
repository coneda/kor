// TODO: replace this with functionality from @wendig/lib

wApp.utils = {
  shorten(str, n = 15) {
    if (str && str.length > n) {
      return str.substr(0, n - 1) + '…'
    }
    return str;
  },
  inGroupsOf(per_row, array, dummy) {
    const result = [];
    let current = [];
    for (const i of array) {
      if (current.length === per_row) {
        result.push(current);
        current = [];
      }
      current.push(i);
    }
    if (current.length > 0) {
      if (dummy !== undefined) {
        while (current.length < per_row) {
          current.push(dummy);
        }
      }
      result.push(current);
    }
    return result;
  },
  toInteger(value) {
    if (Zepto.isNumeric(value)) {
      return parseInt(value);
    }
    return value;
  },
  toArray(value) {
    if (value == null || value == undefined) {
      return [];
    } else {
      return Zepto.isArray(value) ? value : [value];
    }
  },
  uniq(a, toKey = (e) => e) {
    const output = {}

    for (const e of a) {
      const key = toKey(e)
      output[key] = e
    }

    return Object.values(output)
  },
  scrollToTop() {
    if (document.body.scrollTop !== 0 || document.documentElement.scrollTop !== 0) {
      window.scrollBy(0, -50);
      wApp.state.scrollToTopTimeOut = setTimeout(wApp.utils.scrollToTop, 10);
    } else {
      clearTimeout(wApp.state.scrollToTopTimeOut);
    }
  },
  capitalize(value) {
    return value.charAt(0).toUpperCase() + value.slice(1);
  },
  confirm(string) {
    return window.confirm(
      string || wApp.i18n.t(wApp.session.current.locale, 'confirm.sure')
    )
  },
  toIdArray(obj) {
    if (!obj) return null;
    obj = Zepto.isArray(obj) ? obj : obj.split(',');
    return Object.values(obj).map(o => parseInt(o));
  },
  listToArray(value) {
    if (!value) return null;
    return value.split(',').map(v => parseInt(v));
  },
  arrayToList(values) {
    if (!values) return '';
    return values.join(',');
  },
  isoToDate(str) {
    const parts = str.split('-').map(i => parseInt(i));
    return new Date(parts[0], parts[1] - 1, parts[2]);
  },
  isObject(v) {
    if (typeof v !== 'object') return false
    if (Array.isArray(v)) return false
    if (v === null) return false
    if (v instanceof Blob) return false

    return true
  },
  toFormData(values, formData = null, prefix = null) {
    let fd = formData || new FormData()

    for (const [k, v] of Object.entries(values)) {
      let key = (prefix ? `${prefix}[${k}]` : k)

      if (wApp.utils.isObject(v)) {
        fd = wApp.utils.toFormData(v, fd, key)
      } else {
        fd.set(key, v)
      }
    }

    return fd
  },
  deleteNull(object) {
    Object.keys(object).forEach(key => {
      if (object[key] === null) {
        delete object[key]
      }
    })

    return object
  }
}
