Worker  = require './worker'

class FilterWorker extends Worker
  _id : "filter_worker"

  constructor : (@operator) ->
    super()

  process : (data) ->
    try
      @operator data, (error, data) =>  if data then @emit "data:new", data
    catch e
      if e then console.log "#{@_id} error: #{e}"

module.exports = FilterWorker