{EventEmitter}  = require 'events'

ProjectWorker  = require './project-worker'
InjectWorker  = require './inject-worker'
FilterWorker  = require './filter-worker'
AggregateWorker  = require './aggregate-worker'

class Connect extends EventEmitter

  constructor : (@stream, @worker, @id, @topology) ->
    throw new Error "Stream required" if not @stream
    super()

    # register with topology if id and topology are provided
    if @id and @topology then @topology.register @id, @

    @_sinks = []
    @_initWorker()
    @_connectStream()


  _initWorker : () ->
    return unless @worker

    @worker.on "data:new", (data) =>
      @_emit data

  _emit : (data) ->
    @emit "data:new", data
    sink data for sink in @_sinks

  sink : (handler) ->
    @_sinks.push handler

  filter : (fn, id) -> return new Connect @, new FilterWorker(fn), id, @topology

  project : (fn, id) -> return new Connect @, new ProjectWorker(fn), id, @topology

  inject : (fn, id) -> return new Connect @, new InjectWorker(fn), id, @topology

  aggregate : ( aggregator, id ) -> return new Connect @, new AggregateWorker(aggregator), id, @topology

  #merge : () -> return new Connect @

  #join : () -> return new Connect @stream

  process : (data) ->
    process.nextTick () =>
      @worker.process data


  _connectStream : () ->
    return unless @stream
    @stream.on "data:new", (data) =>
      @process data

module.exports = Connect