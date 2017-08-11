{Db} = require '../src/db.coffee'
{createFakeData} = require '../src/fakeData.coffee'

describe 'createFakeData()', ->
  beforeEach -> @db = new Db()

  it 'should create fake data with correct parentId', ->
    createFakeData(@db)
    tree = @db.getTree()
    expect(tree[0]).toEqual
      parentId: null,
      _id: 1,
      name: jasmine.any(String),
      earnings: jasmine.any(Number),
      childEarnings: jasmine.any(Number),
      childrens: jasmine.any(Array)

    expect(tree[0].childrens[0]).toEqual
      parentId: 1,
      _id: jasmine.any(Number),
      name: jasmine.any(String),
      earnings: jasmine.any(Number),
      childEarnings: jasmine.any(Number),
      childrens: jasmine.any(Array)
