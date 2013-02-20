Window  = require './window'

###
#
# Windows accumulate a subset of a stream. Each window must
# implement the process method and emit "event:push" and "event:pop" events
#
###
class SingletoneWindow extends Window

  _key : "singletonwindow"

  constructor : () ->
    super()

  process : (data) ->
    @store.get @_key, (error, value) =>
      throw error if error

      if value then @emit "data:pop", [value]

      @store.put @_key, data, (error, value) =>
        # trigger push event
        @emit "data:push", [data]

module.exports = SingletoneWindow