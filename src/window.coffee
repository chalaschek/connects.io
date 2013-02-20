{EventEmitter}  = require 'events'
{MemoryStore}   = require './store'

###
#
# Windows accumulate a subset of a stream. Each window must
# implement the process method and emit "event:push" and "event:pop" events
#
###
class Window extends EventEmitter

  constructor : ( config={} ) ->
    {@store} = config
    # default to memory store
    @store = new MemoryStore() unless @store
    super()

  process : (data) -> throw new Error "Method must be implemented"

module.exports = Window