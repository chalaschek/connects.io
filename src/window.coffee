{EventEmitter}  = require 'events'

###
#
# Windows accumulate a subset of a stream. Each window must
# implement the process method and emit "event:push" and "event:pop" events
#
###
class Window extends EventEmitter

  constructor : ( ) ->
    super()

  events: () -> return new Error "Method must be implemented"

  process : (data) -> return new Error "Method must be implemented"

module.exports = Window