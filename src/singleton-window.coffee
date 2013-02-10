Window  = require './window'

###
#
# Windows accumulate a subset of a stream. Each window must
# implement the process method and emit "event:push" and "event:pop" events
#
###
class SingletoneWindow extends Window

  constructor : () ->
    super()
    @_event = null

  events: () ->
    # return events in the window
    if @_event then return [@_event] else return []

  process : (data) ->
    # trigger pop event
    if @_event then @emit "event:pop", [@_event]
    # set current event pointer
    @_event = data
    # trigger push event
    @emit "event:push", [data]

module.exports = SingletoneWindow