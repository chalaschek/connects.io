{EventEmitter}    = require 'events'
SingletoneWindow  = require "./singleton-window"
{MemoryStore}     = require './store'
uuid              = require './uuid'
async             = require 'async'
_                 = require 'underscore'

class Aggregator extends EventEmitter

  constructor : ( config={} ) ->
    super()

    {@cumulative, @stats, @window} = config

    if not @stats then @stats = []

    if @cumulative is undefined then @cumulative = true

    if not @window then @window = new SingletoneWindow()

    @_initWindowListeners()

  _initWindowListeners : () ->
    _invokeStats = (events, isAccumulate, callback) =>
      result = {}
      method = if isAccumulate then "accumulate" else "offset"
      async.forEach @stats, (stat, cb) =>
        stat[method] events, (error, data) =>
          result = _.extend result, data
          cb()
      , (error) => return callback error, result

    @window.on "data:push", (events) =>
      _invokeStats events, true, (error, data) =>
        return if error
        @emit "data:new", data

    # only aggregate window pop events if this is not a cumulative stat
    if not @cumulative
      @window.on "data:pop", (events) =>
        _invokeStats events, false, (error, data) =>
          return if error
          if not (@window instanceof SingletoneWindow) then @emit "data:new", data

  process : (data) ->
    process.nextTick () =>
      @window.process data


module.exports = Aggregator