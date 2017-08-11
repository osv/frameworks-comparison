# Server

This is base server that allow to import express routers from `../dist/` directory.

## Install and run

    npm install
    DEBUG=app:* npm start

## How it works

App require each subdirs of `../dist/` and if it exports `getRouter()` than this function will be called with `express` instnance.
Usually to make require in imported module work I need to copy node_modules to dist too

See [api-tree](../prj/api-tree/src/index.coffee) for example
