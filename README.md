# FRONTEND PLAYGROUND

## Motivation

I want to know pros and cons of different framework and want try something bigger than TODOMVC.

I want to have 2 API for testing different FE frameworks in different ways.

1st API is called "tree". I will use it for testing todo-like project and some recursion in components. See [Tree task](#tree-trask) below

2nd API is used for tasting routing.

I want to have monorepo and use makefile to build them all in one command - `make all`.


Project are in [./prj](./prj/) folder. `make all` build them and place dist into `dist/<project-name>/`.
Project may contain FE and BE parts. FE - index.html should be exists, BE - index.js or index.coffee

##  Install And Run

Build directory is in `./dist`. To build all projects run

```bash
make all
./run-server.sh   # DEBUG=app:*
# open url in browser - http://localhost:3000
```

<a name="tree-trask"></a>
## Tree task



Goals:

- try something more than TODO
- find how difficult is to create simple form

Requirements:

- Create, edit, delete companies
- Show companies tree
- Fields: Name, estimated earnings, parent company
- Show total earning per each company including childs:

|                    |     |     |
|--------------------|-----|-----|
| `Company 1`        | 10k | 35k |
| `- Company 1_1`    | 5k  | 10k |
| `-- Company 1_1_1` | 5k  |     |
| `- Company 1_2`    | 15k |     |

- Nesting level is not limited
- Companies is not limited
- No pagination

Backend is located in [./prj/api-tree](./prj/api-tree)

Example of API response:

```js
// GET http://localhost:3000/projects/api-tree
// Content-Type: application/json
[
  {
    "childEarnings": 2000,
    "childrens": [
      {
        "childEarnings": 0,
        "childrens": [],
        "_id": 2,
        "parentId": 1,
        "earnings": 2000,
        "name": "Name2"
      }
    ],
    "_id": 1,
    "parentId": null,
    "earnings": 1000,
    "name": "Name1"
  }
]
```
Example of create API:
```js
// PUT http://localhost:3000/projects/api-tree
// Content-Type: application/json

{
  "name": "Name2",
  "earnings": 2000,
  "parentId": 1
}
```
