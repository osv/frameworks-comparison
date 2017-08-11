'use strict'

expressHandlebars = require 'express-handlebars'
serveStatic =       require 'serve-static'
bodyParser =        require 'body-parser'
serveIndex =        require 'serve-index'
express =           require 'express'
morgan =            require 'morgan'
utils =             require './utils'
app =               express()
debug = require('debug') 'app:server'

app.use morgan('dev')
app.use bodyParser.json()
app.engine 'handlebars', expressHandlebars(defaultLayout: 'main')
app.set 'view engine', 'handlebars'

# Try require all subdirs of dist, if it exports "getRouter" than use in app it
dirs = utils.getDirs('../dist')
for dir in dirs
  try
    plugin = require "../dist/#{dir}"
    if plugin?.getRouter
      try
        app.use "/projects/#{dir}", plugin.getRouter(express)
        debug "Added route /projects/#{dir}"
      catch e
        console.error e

sourceCatalog = [
  ['/projects', '../dist', 'Catalog of projects']
  ['/sources',  '../prj',  'Source files of projects']
  ['/server',   './',      'Source code of server' ]
]

sourceCatalog.forEach ([url, dir]) ->
  app.use url, serveStatic(dir)
  app.use url, serveIndex(dir, {'icons': true})

app.get '/', (_, res) ->
  res.render 'index.handlebars',
    sourceCatalog: sourceCatalog.map ([url, dir, info]) -> {url, info}

app.post '/test', (req, res) ->
  res.status(200).json req.body

module.exports = app
