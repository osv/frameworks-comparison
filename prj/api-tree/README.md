## Create item

`name` should be unique

```sh
PUT http://localhost:3000/projects/api-tree
Content-Type: application/json

{
  "name": "Name1",
  "earnings": 1000
}
#{
#  "_id": 1,
#  "parentId": null,
#  "earnings": 1000,
#  "name": "Name1"
#}
PUT http://localhost:3000/projects/api-tree
Content-Type: application/json

{
  "name": "Name2",
  "earnings": 2000,
  "parentId": 1
}
#{
#  "_id": 2,
#  "parentId": 1,
#  "earnings": 2000,
#  "name": "Name2"
#}
```

## Get tree

```sh
GET http://localhost:3000/projects/api-tree
Content-Type: application/json
#[
#  {
#    "childEarnings": 2000,
#    "childrens": [
#      {
#        "childEarnings": 0,
#        "childrens": [],
#        "_id": 2,
#        "parentId": 1,
#        "earnings": 2000,
#        "name": "Name2"
#      }
#    ],
#    "_id": 1,
#    "parentId": null,
#    "earnings": 1000,
#    "name": "Name1"
#  }
#]

```

## Update

`parentId` cannot be one of childrens id of update item.

```sh
POST http://localhost:3000/projects/api-tree
Content-Type: application/json

{
  "_id": 2,
  "name": "now this item is root",
  "earnings": 2000,
  "parentId": null
}
#{
#  "_id": 2,
#  "parentId": null,
#  "earnings": 2000,
#  "name": "now this item is root"
#}
```

```sh
GET http://localhost:3000/projects/api-tree
Content-Type: application/json
[
  {
    "childEarnings": 0,
    "childrens": [],
    "_id": 1,
    "parentId": null,
    "earnings": 1000,
    "name": "Name1"
  },
  {
    "childEarnings": 0,
    "childrens": [],
    "_id": 2,
    "parentId": null,
    "earnings": 2000,
    "name": "now this item is root"
  }
]
```

## Deletes

```sh
DELETE http://localhost:3000/projects/api-tree/1
#[
#  1
#]
```
