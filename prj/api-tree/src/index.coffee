lokiJs = require('lokijs')

class RequiredFields
  constructor: (@errors = {}) ->
    @name = 'RequiredFields'

class Db
  constructor: () ->
    @loki = new lokiJs()
    @col = @loki.addCollection 'companies', {
      cloneObjects: yes,
      indices: ['parentId']
      }
  clearStore: -> storeById = {}

  getList: -> @col.find({}).map(@_normilizeDoc)

  # change $loki to id
  _normilizeDoc: ({name, earnings, parentId, $loki}) ->
    {name, earnings, parentId, _id: $loki}

  _checkRequiredField: (obj = {}) ->
    errors = {}
    if typeof obj?.name != 'string'
      errors.name = "name is required"
    else if obj?.name?.length > 250
      errors.name = "name should be less 255 chars"
    else if obj?.name?.length < 2
      errors.name = "name should be greater 1 char"
    if typeof obj?.earnings != 'number' or isNaN(+obj?.earnings)
      errors.earnings = "earnings is required"
    else
    if Object.keys(errors).length
      throw new RequiredFields(errors)

  getById: (id) ->
    doc = @col.findOne({$loki: id})
    if doc
      @_normilizeDoc doc
    else
      null

  # Build childrens for doc with this id
  # find id in childrens recursivly, if found - raise error
  _ensureChildrensHaveNoId: (id) ->
    docWithChildrens = {_id: id}
    @_makeTree @getList(), docWithChildrens
    findId = (it, id) -> it.childrens.some((c) ->
      c.parentId == id || findId(c, id))
    if findId docWithChildrens, id
      throw Error 'parentId cannot be equal to id if his children'

  update: (id, payload) ->
    @_checkRequiredField(payload)
    if payload.parentId and not @getById(payload.parentId)
      throw Error "parentId should be null or refference to id"

    if +payload.parentId == +id
      throw Error "parentId should not be same as id"

    @_ensureChildrensHaveNoId id

    doc = @col.findOne({$loki: id})
    if doc
      Object.assign doc,
      name: payload.name
      earnings: payload.earnings
      parentId: payload.parentId || null
      @_normilizeDoc @col.update doc
    else
      throw Error "No document with id '#{id}'"
  createItem: (payload) ->
    @_checkRequiredField(payload)
    if payload.parentId and not @getById(payload.parentId)
      throw Error "parentId should be null or refference to id"
    doc = @col.insert
      name: payload.name
      earnings: payload.earnings
      parentId: payload.parentId || null
    return @_normilizeDoc doc

  getTree: ->
    @_computeChildEarn (@_makeTree @getList())

  _makeTree: (array, parent) ->
    tree = []
    parent = parent or {_id: null}
    children = array.filter (child) -> child.parentId is parent._id
    if children.length
      if !parent._id
        tree = children
      else
        parent.childrens = children
      children.forEach (child) => @_makeTree array, child
    else
      parent.childrens = []
    tree

  _computeChildEarn: (tree) ->
    @_populateChildEarnings tree
    tree

  _populateChildEarnings: (tree) ->
    tree.map((it) =>
      childEarnings = @_populateChildEarnings(it.childrens) or 0
      it.childEarnings = childEarnings
      childEarnings + it.earnings
    ).reduce ((sum, cur) -> sum + cur), 0

  removeItem: (id) ->
    tree = @_makeTree @getList()
    itemsForDelete = @_collectChildrens tree, id
    @col.remove(itemsForDelete)
    itemsForDelete

  _collectChildrens: (tree, id) ->
    result = []
    traverse = (node, addToResult) ->
      if node._id == id
        addToResult = true
      if addToResult
        result.push node._id
      node.childrens.forEach (it) -> traverse it, addToResult
    tree.forEach (node) -> traverse(node, false)
    result

module.exports.getRouter = (express) ->
  router = express.Router()
  db = new Db()

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

# For testing
module.exports.Db = Db
module.exports.RequiredFields = RequiredFields
