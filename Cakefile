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

task 'doc', 'generate documentation', ->
  docco -> log "docs complete", green

task 'build', 'compile source', ->
  build -> log "build complete", green

task 'watch', 'compile and watch', ->
  build true, -> log "watching for changes", green

task 'test', 'run tests', ->
  build -> mocha -> log "tests complete", green

task 'dist', 'create distribution', ->
  # TODO: include docs
  clean -> build -> mocha -> docco -> dist -> log "dist created", green

task 'clean', 'clean generated files', ->
  clean -> log "clean complete", green

task 'all', 'fresh install', ->
  # TODO: include docs
  clean -> install -> build -> mocha -> docco -> log "fresh install complete", green


moduleExists = (name) ->
  try 
    require name 
  catch err 
    log "#{name} required: npm install #{name}", red
    false

log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')


install = (callback) ->
  log 'installing dependencies', blue

  launch "npm", ["install"], callback


dist = (callback) ->
  log 'creating dist', blue

  async   = moduleExists "async"
  wrench  = moduleExists "wrench"

  return unless async and wrench

  conf = JSON.parse fs.readFileSync "#{__dirname}/package.json", "utf-8"

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
  launch 'rm', ['-rf', 'lib', 'docs'], () -> callback?()


mocha = (options, callback) ->
  log 'testing', blue

  return unless moduleExists('mocha')

  if typeof options is 'function'
    callback = options
    options = []
  # add coffee directive
  options.push '--compilers'
  options.push 'coffee:coffee-script'
  
  launch 'mocha', options, callback


walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) ->
          results.push name for name in res
          done(null, results) unless --pending
      else
        results.push file
        done(null, results) unless --pending


docco = (callback) ->
  log 'docing', blue
  return unless moduleExists('docco')
  walk "src", (error, files) ->
    if error then return log "Error reading src: #{err}", red
    launch 'docco', files, callback
