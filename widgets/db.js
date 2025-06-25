import {util} from '@wendig/lib'
import {Database} from '@wendig/lib'
import config from './lib/config'


// init

let dbs = null
let storage = {}
let database = new Database()
onmessage = database.handler

const promises = []

// promises.push(
//   fetch(`${config.env.ROOT_URL}/settings`).then(r => r.json()).then(data => {
//     console.log(data)
//     storage['records'] = data
//   })
// )

Promise.all(promises).then(data => {
  console.log('ALL loaded')
  database.loaded()
})


// actions

database.action('live-legacy', data => {
  const {opts} = data
})


// helpers

// const matchesTags = (record, criteria) => {
//   const tags = criteria['tags']
//   if (!tags) return true
//   if (tags.length == 0) return true

//   for (const t of record['Tags']) {
//     for (const c of tags) {
//       if (t == c) return true
//     }
//   }

//   return false
// }

const sanitizeCriteria = (input) => {
  let criteria = input || {}
  criteria['page'] = criteria['page'] || 1
  criteria['per_page'] = criteria['per_page'] || 24

  return criteria
}

const paginate = (records, criteria, highlight) => {
  const {page, per_page} = criteria
  const total = records.length
  const start = (criteria.page - 1) * criteria.per_page
  const results = records.slice(start, start + criteria.per_page)

  return {
    page,
    per_page,
    total,
    results,
    highlight
  }
}
