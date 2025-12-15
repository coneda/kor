#!/usr/bin/env node

import ejs from 'ejs'
import fs from 'fs'
import crypto from 'crypto'

import 'dotenv/config'
import config from './lib/config.js'

class IndexRenderer {
  constructor(filename) {
    this.file_opts = {encoding: 'utf8'}
    this.filename = filename
  }

  read(filename) {
    return fs.readFileSync(filename, this.file_opts)
  }

  tpl() {
    return this.read(this.filename)
  }

  digest(filename) {
    var hash = crypto.createHash('sha256')
    return hash.update(this.read(filename)).digest('hex').slice(0,9)
  }

  rootUrl() {
    return config.env.ROOT_URL
  }

  stylesheetPath(filename) {
    const file = filename + '?' + this.digest('public/' + filename)
    return `${this.rootUrl()}/${file}`
  }

  scriptPath(filename) {
    return this.stylesheetPath(filename)
  }

  render() {
    return ejs.render(this.tpl(), this)
  }
}

process.argv.slice(2).forEach(function (val) {
  var ir = new IndexRenderer(val)
  console.log(ir.render())
})
