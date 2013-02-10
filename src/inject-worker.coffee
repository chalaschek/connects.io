Worker  = require './worker'

class InjectWorker extends Worker
  _id : "inject_worker"

  constructor : (@operator) ->
    super()

  _extend : (source, destination={}) ->
    destination[key] = val for key,val of source
    return destination

  process : (data) ->
    try
      @operator data, (error, inject) =>
        # TODO: consider cloning data
        @emit "event:new", @_extend inject, data
    catch e
      if e then console.log "#{@_id} error: #{e}"

module.exports = InjectWorker