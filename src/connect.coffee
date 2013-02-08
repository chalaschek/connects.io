{EventEmitter}  = require 'events'

ProjectConnect = require './project-connect'

class Connect extends EventEmitter

  constructor : (@stream, @worker) ->
    return new Error "Stream required" if not @stream
    super()

    # window
    @_window = undefined

    # handler
    @_handler = undefined

    @_sinks = []
    @_connectStream()

  execute : (data) ->
    return new Error "Worker not definted" if not @worker
    return @worker data

  sink : (handler) ->
    @_sinks.push handler

  filter : (fn) -> return new ProjectConnect @stream, fn

  project : (fn) -> return new Connect @stream, fn

  inject : (fn) -> return new Connect @stream, fn

  merge : () -> return new Connect @stream

  aggregate : (fn, windowType, subType, lenthOrTime, emitFrequency) -> return new Connect @stream

  join : () -> return new Connect @stream

  _execute : (data) ->
    _data = @execute data
    @emit "event:new", _data
    sink _data for sink in @_sinks

  _connectStream : () ->
    return unless @stream
    @stream.on "event:new", (data) =>
      @_execute data

module.exports = Connect