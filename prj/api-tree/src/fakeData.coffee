faker = require('faker')

module.exports.createFakeData = (db) ->
  faker.seed 77077

  createCompany = ({maxChilds, parentId, nestedLevel}) ->
    i = 0
    maxChilds = Math.max(faker.random.number({min: 0, max: maxChilds}),
                         faker.random.number({min: 0, max: maxChilds}))
    while i < maxChilds
      name = faker.company.companyName()
      earnings = faker.random.number({max: 999}) * 1000
      # create company and skipp errors
      company = null
      try
        company = db.createItem {
          name,
          earnings,
          parentId: parentId
        }
      if company && nestedLevel > 1
        createCompany
          maxChilds: faker.random.number({min: 0, max: maxChilds}),
          parentId: company._id,
          nestedLevel: nestedLevel - 1
      i++

  i = 0
  while i < 6
    createCompany
      maxChilds: 9
      parentId: null
      nestedLevel: 5
    i++
