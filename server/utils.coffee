fs = require 'fs'
path = require 'path'

module.exports.getDirs = (rootDir) ->
  files = fs.readdirSync(rootDir)
  dirs = []
  for file in files
    if file[0] != '.'
      filePath = path.join rootDir, file
      stat = fs.statSync(filePath)
      if stat.isDirectory()
        dirs.push(file)
  return dirs
