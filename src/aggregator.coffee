{EventEmitter}    = require 'events'

SingletoneWindow  = require "./singleton-window"

{MemoryStore}     = require './store'

uuid              = require './uuid'

class Aggregator extends EventEmitter

  constructor : ( config={} ) ->
    super()

    @_id = uuid()

    @_key = "#{@_id}:aggregate"

    {@stats, @window, @groupBy, @cumulative, @emitFrequency, @store} = config

    if not @stats then @stats = []

    if not @window then @window = new SingletoneWindow()

    if not @store then @store = new MemoryStore()

    @_initEmitter()

    @_initWindowListeners()

  _initWindowListeners : () ->

    @window.on "data:push", (events) =>
      @_accumulate events

    if not @cumulative
      @window.on "data:pop", (events) =>
        @_offset events


  _emitValue : () ->
    @_value (error, value) =>
      @emit "data:new", value


  _initEmitter : () ->
    if @emitFrequency
      @_interval = setInterval () =>
        @_emitValue()
      , @emitFrequency
    else
      @on "aggregate:updated:accumulate", (data) =>
        @_emitValue()

      @on "aggregate:updated:offset", (data) =>
        # only emit event if this is not a singleton window
        # in that case it will be triggered by the accumulate method associated with the push
        if not (@window instanceof SingletoneWindow) then @_emitValue()

  _accumulate : (events) ->
    # handle each stat
    for stat in @stats
      for data in events
        continue unless data?[stat.aggregateField] isnt null

        if @groupBy
          # if not field to group by then ignore
          if not data?[@groupBy] then continue
          # get groups
          _groups = data[@groupBy]
          # convert to array if needed
          if not (_groups instanceof Array)
            _groups = [_groups]
          # sum each group
          for group in _groups
            #lazy init
            if not @aggregate[group] then @aggregate[group] = {}
            if not @aggregate[group][stat.outputName] then @aggregate[group][stat.outputName] = 0
            # perform aggregate calc
            @aggregate[group][stat.outputName] = stat.accumulate @aggregate[group][stat.outputName], data[stat.aggregateField]
        else
          # lazy init
          if not @aggregate[stat.outputName] then @aggregate[stat.outputName] = 0
          # perform aggregate calc
          @aggregate[stat.outputName] = stat.accumulate @aggregate[stat.outputName], data[stat.aggregateField]

    @emit "aggregate:updated:accumulate"

  _offset : (events) ->
    return if @cumulative
    _size = @window.size()

    # handle each stat
    for stat in @stats
      for data in events
        continue unless data?[stat.aggregateField] isnt null
        # handle group bys
        if @groupBy
          # if not field to group by then ignore
          if not data?[@groupBy] then continue
          # get groups
          _groups = data[@groupBy]
          # convert to array if needed
          if not (_groups instanceof Array)
            _groups = [_groups]
          # sum each group
          for group in _groups
            continue if not @aggregate[group]?[stat.outputName]
            # perform aggregate calc
            @aggregate[group][stat.outputName] = stat.offset @aggregate[group][stat.outputName], data[stat.aggregateField], _size
        else
          continue if not @aggregate[stat.outputName]
          # perform aggregate calc
          @aggregate[stat.outputName] = stat.offset @aggregate[stat.outputName], data[stat.aggregateField], _size

    @emit "aggregate:updated:offset"



  value : (callback) ->
    @store.get @_key, (error, agg) =>
      return callback error if error
      clone = {}
      clone[key]=val for key,val of agg
      return callback null, clone

  process : (data) ->
    process.nextTick () =>
      @window.process data


module.exports = Aggregator