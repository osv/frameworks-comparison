'use strict'

expressHandlebars = require('express-handlebars')
serveStatic = require('serve-static')
bodyParser = require('body-parser')
serveIndex = require('serve-index')
express = require('express')
morgan = require('morgan')
app = express()

app.use morgan('dev')
app.use bodyParser.json()
app.engine 'handlebars', expressHandlebars(defaultLayout: 'main')
app.set 'view engine', 'handlebars'

sourceCatalog = [
  ['/projects', '../dist', 'Catalog of projects']
  ['/sources',  '../prj',  'Source files of projects']
  ['/server',   './',      'Source code of server' ]
]

sourceCatalog.forEach ([url, dir]) ->
  app.use(url, serveStatic(dir))
  app.use(url, serveIndex(dir, {'icons': true}))

app.get '/', (_, res) ->
  res.render 'index.handlebars',
    sourceCatalog: sourceCatalog.map ([url, dir, info]) -> {url, info}

module.exports = app
