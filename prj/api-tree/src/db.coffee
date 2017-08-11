lokiJs = require('lokijs')

class RequiredFields
  constructor: (@errors = {}) ->
    @name = 'RequiredFields'

class Db
  constructor: () ->
    @loki = new lokiJs()
    @col = @loki.addCollection 'companies', {
      unique: ['name']
      cloneObjects: yes,
      indices: ['parentId']
      }

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
    doc = @col.get(id)
    if doc
      @_normilizeDoc doc
    else
      null

  # Build childrens for doc with this id
  # find id in childrens recursivly, if found - raise error
  _ensureChildrensHaveNoId: (id, newParentId) ->
    docWithChildrens = {_id: id}
    @_makeTree @getList(), docWithChildrens
    findId = (it, id) -> it.childrens.some((c) ->
      c._id == id || findId(c, id))
    if findId docWithChildrens, newParentId
      throw Error 'parentId cannot be equal to id if his children'

  update: (id, payload) ->
    @_checkRequiredField(payload)
    if payload.parentId and not @getById(payload.parentId)
      throw Error "parentId should be null or refference to id"

    if +payload.parentId == +id
      throw Error "parentId should not be same as id"

    if payload.parentId
      @_ensureChildrensHaveNoId id, payload.parentId

    doc = @col.get(id)
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
    itemsForDelete = @_collectChildrens tree, parseInt id
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

module.exports = {Db, RequiredFields}
