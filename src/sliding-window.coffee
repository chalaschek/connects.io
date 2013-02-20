Window  = require './window'

###
#
# Windows accumulate a subset of a stream. Each window must
# implement the process method and emit "data:push" and "data:pop" events
#
###
class SlidingWindow extends Window

  _key : "slidingwindow"

  constructor : (@n) ->
    super()

  purge : () -> throw new Error "Method must be implemented"

  process : (data) -> throw new Error "Method must be implemented"



class SlidingTimeWindow extends SlidingWindow

  _key : "slidingtimewindow"

  _defaultPurgeInterval : 100

  constructor : (@n, @windowPurgeInterval=@_defaultPurgeInterval) ->
    if @n < 1 then throw new Error "Time interval must be greater than 1"
    super @n

    @_initTicker()

  _initTicker : () ->
    @_interval = setInterval () =>
      @purge()
    , @windowPurgeInterval

  purge : () ->
    # TODO: migrate to b+ index
    now = Date.now()
    @store.get @_key, (error, _window=[]) =>
      throw error if error

      _events = []
      # find events to remove
      for entry, i in _window
        if now - entry.timestamp >= @n
          _events.push entry.data
        else
          break

      if _events.length > 0
        # trigger push event
        # remove from events
        _window = _window.slice i
        @store.put @_key, _window, (error) =>
          throw error if error
          @emit "data:pop", _events


  process : (data) ->
    @store.get @_key, (error, _window=[]) =>
      throw error if error
      # add to event queue
      _window.push
        data: data
        timestamp: Date.now()

      # TODO: index data

      @store.put @_key, _window, (error) =>
        throw error if error
        # trigger push event
        @emit "data:push", [data]



module.exports =
  SlidingTimeWindow : SlidingTimeWindow