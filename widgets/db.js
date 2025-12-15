import {util, Database} from '@wendig/lib'
import config from './lib/config'

const request = (url, opts = {}) => {
  url = `${config.env.ROOT_URL}${url}`

  if (config.env == 'development') {
    opts['cache'] = 'no-store'
  }

  return fetch(url, opts)
}


// init

let dbs = null
let storage = {}
let lookup = {}
let database = new Database()
onmessage = database.handler

const promises = []

const preload = [
  'session',
  'settings',
  'statistics',
  'translations',
  'kinds',
  'relations',
  'entities',
  'collections',
  'authority_groups',
  'authority_group_categories'
]

for (const ds of preload) {
  promises.push(
    request(`/static/${ds}.json`).then(r => r.json()).then(data => {
      storage[ds] = data
    })
  )
}

Promise.all(promises).then(data => {
  lookup['kinds'] = util.indexBy(storage['kinds']['records'], 'id')
  lookup['collections'] = util.indexBy(storage['collections']['records'], 'id')

  lookup['authority_groups'] = util.indexBy(storage['authority_groups']['records'], 'id')
  lookup['authority_group_categories'] = util.indexBy(storage['authority_group_categories']['records'], 'id')
  storage['root_authority_groups'] = []
  storage['root_authority_group_categories'] = []
  for (const agc of storage['authority_group_categories']['records']) {
    const parent_id = agc['parent_id']
    if (parent_id) {
      const parent = lookup['authority_group_categories'][parent_id]
      parent['children'] = parent['children'] || []
      parent['children'].push(agc)
    } else {
      storage['root_authority_group_categories'].push(agc)
    }
  }
  for (const ag of storage['authority_groups']['records']) {
    const agc_id = ag['authority_group_category_id']
    if (agc_id) {
      const agc = lookup['authority_group_categories'][agc_id]
      if (!agc) continue

      agc['authority_groups'] = agc['authority_groups'] || []
      agc['authority_groups'].push(ag)
    } else {
      storage['root_authority_groups'].push(ag)
    }
  }

  database.loaded()
})


// actions

database.action('api', data => {
  const opts = data['opts']
  const criteria = sanitizeCriteria(opts['data'])
  opts['method'] = (opts['method'] || 'get').toLowerCase()

  if (opts['method'] == 'get') {
    if (opts['url'] == '/session') return storage['session']
    if (opts['url'] == '/settings') return storage['settings']
    if (opts['url'] == '/statistics') return storage['statistics']
    if (opts['url'] == '/translations') return storage['translations']
    if (opts['url'] == '/kinds') return storage['kinds']
    if (opts['url'] == '/relations') return storage['relations']
    if (opts['url'] == '/collections') return storage['collections']
    
    if (opts['url'] == '/entities') return fetchEntities(criteria)
    if (opts['url'] == '/relationships') return fetchRelationships(criteria)
    if (opts['url'] == '/authority_group_categories') return fetchAuthorityGroupCategories(criteria)
    if (opts['url'] == '/authority_groups') return fetchAuthorityGroups(criteria)

    let m = null

    m = opts['url'].match(/^\/entities\/(\d+)$/)
    if (m) return fetchEntity(m[1])

    m = opts['url'].match(/^\/kinds\/(\d+)$/)
    if (m) return lookup['kinds'][m[1]]

    m = opts['url'].match(/^\/authority_groups\/(\d+)$/)
    if (m) return lookup['authority_groups'][m[1]]

    m = opts['url'].match(/^\/authority_group_categories\/(\d+)$/)
    if (m) return lookup['authority_group_categories'][m[1]]
  }

  console.error('ERROR: STATIC: DONT KNOW HOW TO DEAL WITH', data)
})


// helpers

const fetchFile = (url) => {
  const u = (url.match(/\.json$/) ? url : `${url}.json`)

  return request(u).then(r => r.json())
}

const fetchAuthorityGroupCategories = (criteria) => {
  const parent_id = criteria['parent_id']
  const results = (
    parent_id ?
    lookup['authority_group_categories'][parent_id]['children'] :
    storage['root_authority_group_categories']
  )

  return paginate(results, {per_page: 'max'})
}

const fetchAuthorityGroups = (criteria) => {
  const agc_id = criteria['authority_group_category_id']
  const results = (
    agc_id ?
    lookup['authority_group_categories'][agc_id]['authority_groups'] :
    storage['root_authority_groups']
  )

  return paginate(results, {per_page: 'max'})
}

const fetchEntities = (criteria) => {
  const results = storage['entities'].filter(entity => {
    if (!matchesKind(entity, criteria)) return false
    if (!matchesName(entity, criteria)) return false
    if (!matchesTags(entity, criteria)) return false
    if (!matchesGroup(entity, criteria)) return false

    return true
  })

  const dataset = paginate(results, criteria)
  return loadEntities(dataset, criteria)
}

const fetchRelationships = (criteria) => {
  const id = criteria['from_entity_id']
  return fetchFile(`/static/relationships/${id}`).then(data => {
    let results = data.filter(r => {
      if (!matchesSimple(r['relation_name'], criteria['relation_name'])) return false
      if (!notMatchesSimple(r['to']['kind_id'], criteria['except_to_kind_id'])) return false
      if (!matchesSimple(r['to']['kind_id'], criteria['to_kind_id'])) return false

      return true
    })

    return paginate(results, criteria)
  })
}

const fetchEntity = (id) => {
  return fetchFile(`/static/entities/${id}`).then(data => {
    data['kind'] = lookup['kinds'][data['kind_id']]
    data['collection'] = lookup['collections'][data['collection_id']]
    data['fields'] = data['kind']['fields'].map(f => {
      let field = structuredClone(f)
      field['value'] = data['dataset'][field['name']]

      return field
    })

    return data
  })
}

const matchesSimple = (value, search) => {
  if (!search) return true

  return search == value
}

const notMatchesSimple = (value, search) => {
  if (!search) return true

  return search != value
}

const matchesName = (entity, criteria) => {
  const name = criteria['name']
  if (!name) return true

  const m = entity['name'].match(new RegExp(name, 'i'))
  return m || entity['id'] == name || entity['uuid'] == name
}

const matchesKind = (entity, criteria) => {
  const kind_id = criteria['kind_id']
  if (!kind_id) return true

  return kind_id == entity['kind_id']
}

const matchesTags = (entity, criteria) => {
  const tags = criteria['tags']
  if (!tags) return true
  if (tags.length == 0) return true

  for (const t of entity['tags']) {
    for (const c of tags) {
      if (t == c) return true
    }
  }

  return false
}

const matchesGroup = (entity, criteria) => {
  const id = criteria['authority_group_id']
  if (!id) return true

  const entity_ids = lookup['authority_groups'][id]['entity_ids']
  return entity_ids.indexOf(entity['id']) != -1
}

const sanitizeCriteria = (input) => {
  let criteria = input || {}
  criteria['page'] = criteria['page'] || 1
  criteria['per_page'] = criteria['per_page'] || 24

  toInt(criteria, 'page')
  if (criteria['per_page'] != 'max') {
    toInt(criteria, 'per_page')
  }
  toInt(criteria, 'kind_id')

  return criteria
}

const toInt = (data, key) => {
  if (!data[key]) return
  if (data[key] == 'max') return

  data[key] = parseInt(data[key])
}

const loadEntities = (dataset, criteria = {}) => {
  const ids = dataset['records'].map(e => e['id'])
  const ep = Promise.all(ids.map(id => fetchEntity(id)))
  const rp = Promise.all(ids.map(id => {
    return fetchRelationships({
      from_entity_id: id,
      to_kind_id: criteria['related_kind_id'],
      page: 1,
      per_page: criteria['related_per_page'] || 'max'
    })
  }))

  return Promise.all([ep, rp]).then(data => {
    const [entities, rels] = data
    for (let i = 0; i < entities.length; i++) {
      entities[i]['related'] = rels[i]['records']
      dataset['records'].push(entities[i])
    }
    
    dataset['records'] = entities
    
    return dataset
  })
}

const paginate = (records, criteria) => {
  const {page, per_page} = criteria
  let results = records
  let total = records.length

  if (criteria['sort'] == 'random') {
    results = util.shuffle(results)
  }

  if (criteria['sort'] == 'created_at') {
    results = util.sortBy(results, e => e['created_at'])

    if (criteria['direction'] == 'desc') results.reverse()
  }

  if (per_page && per_page != 'max') {
    const start = (criteria.page - 1) * criteria.per_page
    results = results.slice(start, start + criteria.per_page)
  }

  return {
    page,
    per_page,
    total,
    records: results
  }
}