{Db} = require './db.coffee'
{createFakeData} = require './fakeData.coffee'

module.exports.getRouter = (express) ->
  router = express.Router()
  db = new Db()

  createFakeData(db)

  handleError = (res, e, code = 500) ->
    if e.message
      res.send(500, {error: e.message})
    else
      res.send(500, e)
  router.get '/', (req, res) ->
    res.status(200).json db.getTree()

  router.put '/', (req, res) ->
    try
      res.status(200).json db.createItem req.body
    catch e
      handleError res, e

  router.post '/', (req, res) ->
    {_id, name, earnings, parentId} = req.body || {}
    try
      res.status(201).json db.update _id, {name, earnings, parentId}
    catch e
      handleError res, e

  router.delete '/:id', (req, res) ->
    try
      res.status(200).json db.removeItem req.params.id
    catch e
      handleError res, e

  router.get '/:id', (req, res) ->
    try
      doc = db.getById req.params.id
      if doc
        res.status(200).toJson doc
      else
        res.status(404)
    catch e
      handleError res, e
