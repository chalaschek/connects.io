files = [
  'lib'
  'src'
]

distFiles = [
  'lib'
  'test'
  'docs'
  'examples'
  'index.js'
  'package.json'
  'Readme.md'
  'History.md'
  'LICENSE'
]

fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'

try
  which = require('which').sync
catch err
  if process.platform.match(/^win/)?
    console.log 'WARNING: the which module is required for windows\ntry: npm install which'
  which = null

# ANSI Terminal Colors
bold = '\x1b[0;1m'
green = '\x1b[0;32m'
blue = '\x1b[1;36m'
reset = '\x1b[0m'
red = '\x1b[0;31m'

task 'docs', 'generate documentation', ->
  docco -> log "docs complete", green

task 'build', 'compile source', ->
  build -> log "build complete", green

task 'watch', 'compile and watch', ->
  build true, -> log "watching for changes", green

task 'test', 'run tests', ->
  build -> mocha -> log "tests complete", green

task 'dist', 'create distribution', ->
  #clean -> build -> mocha -> docco -> dist -> log "dist created", green
  clean -> build -> mocha -> dist -> log "dist created", green

task 'clean', 'clean generated files', ->
  clean -> log "clean complete", green

dist = (callback) ->
    fs     = require("fs")
    async = require "async"
    wrench = require('wrench')

    read = (filename) ->
      fs.readFileSync "#{__dirname}/#{filename}", "utf-8"

    conf = JSON.parse(read "package.json")

    name = conf.name
    version = conf.version
    tarname= "#{name}-#{version}"
    tarball= "#{tarname}.tar.gz"

    wrench.rmdirSyncRecursive "./#{tarname}", true
    fs.mkdirSync "./#{tarname}"

    async.forEach distFiles, (file, cb) ->
      launch "cp", ["-R", file, "./#{tarname}"], cb
    , (error) ->
      if error
        log error, red
        fs.rmdirSync "./#{tarname}"
        return callback()
      
      launch "tar", ["cvfz", "./dist/#{tarball}", "./#{tarname}"], (err) ->
        wrench.rmdirSyncRecursive "./#{tarname}", true
        return callback()

walk = (dir) ->
  results = []
  fs.readdirSync dir, (err, list) ->
    return [] if err
    pending = list.length
    return results unless pending
    for name in list
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        _results = walk file
        results.push name for name in _results
        return results unless --pending
      else
        results.push file
        return results unless --pending


log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')

launch = (cmd, options=[], callback=(()->)) ->
  cmd = which(cmd) if which
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', callback

build = (watch, callback) ->
  log 'building', blue
  if typeof watch is 'function'
    callback = watch
    watch = false

  options = ['-c', '-b', '-o' ]
  options = options.concat files
  options.unshift '-w' if watch
  launch 'coffee', options, callback

clean = (callback) ->
  log 'cleaning', blue
  launch 'rm', ['-rf', 'lib'], () -> callback?()

moduleExists = (name) ->
  try 
    require name 
  catch err 
    log "#{name} required: npm install #{name}", red
    false


mocha = (options, callback) ->
  log 'testing', blue
  #if moduleExists('mocha')
  if typeof options is 'function'
    callback = options
    options = []
  # add coffee directive
  options.push '--compilers'
  options.push 'coffee:coffee-script'
  
  launch 'mocha', options, callback

docco = (callback) ->
  log 'docing', blue
  #if moduleExists('docco')
  files = walk './src'
  #files = require("wrench").readdirSyncRecursive 'src'
  console.log files
  launch 'docco', files, callback
