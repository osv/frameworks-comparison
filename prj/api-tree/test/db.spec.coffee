{Db, RequiredFields} = require './../src/db.coffee'

describe 'Db', ->
  beforeEach -> @db = new Db()

  describe 'getList()', ->
    it 'should return values of @storeById', ->
      @db.createItem name: 'name1', earnings: 100
      @db.createItem name: 'name2', earnings: 200
      expect(@db.getList()).toEqual [
        {name: 'name1', earnings: 100, parentId: null, _id: 1}
        {name: 'name2', earnings: 200, parentId: null, _id: 2}
      ]

  describe 'createItem()', ->
    it 'should create item if parentId is id of other item', ->
      {_id} = @db.createItem name: 'parent', earnings: 999
      doc = @db.createItem name: 'child name', earnings: 2, parentId: _id
      expect(doc).toEqual(name: 'child name', earnings: 2, parentId: _id, _id: jasmine.any(Number))

    it 'should rise error if name not unique', ->
      f = => @db.createItem name: 'child name', earnings: 1
      f()
      expect(f).toThrowError(/Duplicate key for property name/)

    it 'should rise error if parentId is not null and not valid id', ->
      f = => @db.createItem name: 'child name', earnings: 1, parentId: 4444
      expect(f).toThrowError('parentId should be null or refference to id')

    it 'should rise error if missing name', ->
      try
        @db.createItem earnings: 1
      catch e
        catchedError = yes
        expect(e.errors).toEqual name: 'name is required'
      expect(catchedError).toBeTruthy()
    it 'should rise error if 1 < length > 255', ->
      try
        @db.createItem name: '1', earnings: 1
      catch e
        catchedError = yes
        expect(e.errors).toEqual name: 'name should be greater 1 char'
      expect(catchedError).toBeTruthy()

      try
        @db.createItem name: '1'.repeat(256), earnings: 1
      catch e
        catchedError = yes
        expect(e.errors).toEqual name: 'name should be less 255 chars'
      expect(catchedError).toBeTruthy()

      expect(=> @db.createItem name: 'x'.repeat(2), earnings: 1).not.toThrowError()
      expect(=> @db.createItem name: 'x'.repeat(255), earnings: 1).not.toThrowError()

    it 'should rise error if missing earnings', ->
      try
        @db.createItem name: 'some name'
      catch e
        catchedError = yes
        expect(e.errors).toEqual earnings: 'earnings is required'
      expect(catchedError).toBeTruthy()

      expect(=> @db.createItem name: 'name', earnings: '').toThrow()
      expect(=> @db.createItem name: 'name', earnings: NaN).toThrow()
      expect(=> @db.createItem name: 'name', earnings: {}).toThrow()
      expect(=> @db.createItem name: 'name', earnings: 0).not.toThrow()

  describe 'getTree()', ->
    it 'should return array of items that have childrens', ->
      item1 = @db.createItem(name: 'name1', earnings: 50)._id
      item2 = @db.createItem(name: 'name2', earnings: 10)._id
      item2_1 = @db.createItem(name: 'name2_1', earnings: 5, parentId: item2)._id
      item2_2 = @db.createItem(name: 'name2_2', earnings: 5, parentId: item2)._id
      item2_1_1 = @db.createItem(name: 'name2_1_1', earnings: 5, parentId: item2_1)._id

      tree = @db.getTree()

      expect(tree).toEqual [
        {name: 'name1', earnings: 50, childEarnings: 0, parentId: null, _id: item1, childrens: []}
        {
          name: 'name2'
          parentId: null
          _id: item2
          earnings: 10
          childEarnings: 15
          childrens: [
            {
              name: 'name2_1'
              parentId: item2
              _id: item2_1
              earnings: 5
              childEarnings: 5
              childrens: [
                {name: 'name2_1_1', earnings: 5, childEarnings: 0, parentId: item2_1, _id: item2_1_1, childrens: []}
            ]}
            {name: 'name2_2', earnings: 5, childEarnings: 0, parentId: item2, _id: item2_2, childrens: []}
        ]}
      ]

  describe 'removeItem()', ->
    it 'should cascade delete item where parentId is given id', ->
      item1 = @db.createItem(name: 'name1', earnings: 50)._id
      item2 = @db.createItem(name: 'name2', earnings: 10)._id
      item2_1 = @db.createItem(name: 'name2_1', earnings: 5, parentId: item2)._id
      item2_2 = @db.createItem(name: 'name2_2', earnings: 5, parentId: item2)._id
      item2_1_1 = @db.createItem(name: 'name2_1_1', earnings: 5, parentId: item2_1)._id

      @db.removeItem(item2)
      expect(@db.getList().map((it) -> it.name)).toEqual(['name1'])

  describe 'update()', ->
    it 'should update item', ->
      item1id = @db.createItem(name: 'name1', earnings: 50)._id
      updatedItem = @db.update item1id, name: 'changed name', earnings: 100
      item = @db.getById(item1id)
      expect(item).toEqual {name: 'changed name', earnings: 100, parentId: null, _id: item1id}

    it 'should raise error if id not exists', ->
      expect(=>
        updatedItem = @db.update 7777, name: 'changed name', earnings: 100
      ).toThrowError("No document with id '7777'")

    it 'should raise error if id equal to parentId', ->
      itemId = @db.createItem(name: 'name1', earnings: 50)._id
      expect(=>
        updatedItem = @db.update itemId, name: 'changed name', earnings: 100, parentId: itemId
      ).toThrowError("parentId should not be same as id")

    it 'should call earnings tree correct', ->
      item2 = @db.createItem(name: 'name2', earnings: 10)._id
      item2_1 = @db.createItem(name: 'name2_1', earnings: 5, parentId: item2)._id
      item2_2 = @db.createItem(name: 'name2_2', earnings: 5, parentId: item2)._id
      item2_1_1 = @db.createItem(name: 'name2_1_1', earnings: 5, parentId: item2_1)._id

      expect(@db.getTree()[0].childEarnings).toBe 15
      updatedItem = @db.update item2_2, name: 'name2_2 changed', earnings: 500, parentId: item2
      expect(@db.getTree()[0].childEarnings).toBe 510

    it 'should raise error if parentId is one of id of childrens', ->
      item2 = @db.createItem(name: 'name2', earnings: 10)._id
      item2_1 = @db.createItem(name: 'name2_1', earnings: 5, parentId: item2)._id
      item2_2 = @db.createItem(name: 'name2_2', earnings: 5, parentId: item2)._id
      item2_1_1 = @db.createItem(name: 'name2_1_1', earnings: 5, parentId: item2_1)._id

      expect(=>
        updatedItem = @db.update item2, name: 'name2', earnings: 10, parentId: item2_2
      ).toThrowError('parentId cannot be equal to id if his children')
