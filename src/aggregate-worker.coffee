Worker  = require './worker'

class AggregateWorker extends Worker
  _id : "aggregate_worker"

  constructor : (@aggregator) ->
    super()

    @_initEmitter()

  _initEmitter : () ->
    @aggregator.on "event:new", (data) => @emit "event:new", data

  process : (data) ->
    try
      @aggregator.process data
    catch e
      if e then console.log "#{@_id} error: #{e}"

module.exports = AggregateWorker