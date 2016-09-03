#!/usr/bin/env node
'use strict';

var ejs = require('ejs');
var fs = require('fs');
var crypto = require('crypto');

class IndexRenderer {
  constructor(filename) {
    this.file_opts = {encoding: 'utf8'};
    this.filename = filename
  }

  read(filename) {
    return fs.readFileSync(filename, this.file_opts);
  }

  tpl() {
    return this.read(this.filename);
  }

  digest(filename) {
    var hash = crypto.createHash('sha256');
    return hash.update(this.read(filename)).digest('hex').slice(0,9);
  }

  stylesheet_path(filename) {
    return filename + '?' + this.digest('public/' + filename);
  }

  script_path(filename) {
    return this.stylesheet_path(filename);
  }

  render() {
    return ejs.render(this.tpl(), this);
  }
}

process.argv.slice(2).forEach(function (val) {
  var ir = new IndexRenderer(val);
  console.log(ir.render());
});
