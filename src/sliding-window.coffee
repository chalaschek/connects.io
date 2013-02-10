Window  = require './window'

###
#
# Windows accumulate a subset of a stream. Each window must
# implement the process method and emit "event:push" and "event:pop" events
#
###
class SlidingWindow extends Window

  constructor : (@n) ->
    @_window = []
    @_index = {}
    super()

  events: () ->
    return @_events

  purge : () -> return new Error "Method must be implemented"

  process : (data) -> return new Error "Method must be implemented"



class SlidingTimeWindow extends SlidingWindow

  _defaultPurgeInterval : 100

  constructor : (@n, @windowPurgeInterval=@_defaultPurgeInterval) ->
    if @n < 1 then return new Error "Time interval must be greater than 1"
    super @n

    @_initTicker()

  _initTicker : () ->
    @_interval = setInterval () =>
      @purge()
    , @windowPurgeInterval

  events: () ->
    return @_window

  purge : () ->
    # TODO: migrate to b+ index
    now = Date.now()
    _events = []
    # find events to remove
    for entry, i in @_window
      if now - entry.timestamp > @n
        _events.push entry.data
      else
        break

    #console.log @_events.length
    if _events.length > 0
      # trigger push event
      @emit "event:pop", _events
      # remove from events
      @_window = @_window.slice i
  
  process : (data) ->
    #console.log "sliding window processing data"
    # add to event queue
    @_window.push
      data: data
      timestamp: Date.now()

    # TODO: index data

    # trigger push event
    @emit "event:push", [data]



module.exports =
  SlidingTimeWindow : SlidingTimeWindow