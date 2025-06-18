
import './app'
import './lib/config'

import api from './lib/api.instance'
window.wApp.api = api

Zepto.ajax = wApp.api.request

import '../tmp/widgets/coffee'

import './lib/clipboard'
import './lib/editor'
import './lib/form'
import './lib/history'
import './lib/i18n'
import './lib/info'
import './lib/page'
import './lib/session'
import './lib/wikidata'



