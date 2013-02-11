Worker  = require './worker'

class ProjectWorker extends Worker
  _id : "project_worker"

  constructor : (@operator) ->
    super()

  process : (data) ->
    try
      @operator data, (error, projected) => @emit "data:new", projected
    catch e
      if e then console.log "#{@_id} error: #{e}"

module.exports = ProjectWorker