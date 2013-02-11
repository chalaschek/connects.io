{EventEmitter}  = require 'events'

ProjectWorker  = require './project-worker'
InjectWorker  = require './inject-worker'
FilterWorker  = require './filter-worker'
AggregateWorker  = require './aggregate-worker'

class Connect extends EventEmitter

  constructor : (@stream, @worker) ->
    return new Error "Stream required" if not @stream
    super()
    @_sinks = []
    @_initWorker()
    @_connectStream()


  _initWorker : () ->
    return unless @worker

    @worker.on "data:new", (data) =>
      @emit "data:new", data
      sink data for sink in @_sinks


  sink : (handler) ->
    @_sinks.push handler

  filter : (fn) -> return new Connect @, new FilterWorker fn

  project : (fn) -> return new Connect @, new ProjectWorker fn

  inject : (fn) -> return new Connect @, new InjectWorker fn

  #merge : () -> return new Connect @

  aggregate : ( aggregator ) -> return new Connect @, new AggregateWorker aggregator

  #join : () -> return new Connect @stream

  process : (data) ->
    process.nextTick () =>
      @worker.process data


  _connectStream : () ->
    return unless @stream
    @stream.on "data:new", (data) =>
      @process data

module.exports = Connect