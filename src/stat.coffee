uuid          = require './uuid'
{MemoryStore} = require './store'


class Stat

  id : "stat_interface"

  defaultOutputName : "stat_name"

  ###
  constructor : (config) ->#@aggregateField, @outputName=@defaultOutputName) ->
    # create interal id
    @_id = uuid.uuid()
    # set configs
    {@aggregateField, @outputName, @cumulative, @store} = config
    # default output name if needed
    @outputName = @defaultOutputName unless @outputName
    # cumulative by default
    @cumulative = true unless @cumulative isnt null
    # default to memory store
    @store = new MemoryStore() unless @store

    throw new Error "Aggregate field must be specified" if not @aggregateField

  ###

  constructor : (@aggregateField, @outputName=@defaultOutputName) ->
    throw new Error "Aggregate field must be specified" if not @aggregateField


  accumulate : (currentAggregateValue, newValue) -> throw new Error "Method must be implemented"

  offset : (currentAggregateValue, oldValue) -> throw new Error "Method must be implemented"



class SumStat extends Stat

  id : "sum_stat"

  defaultOutputName : "sum"

  accumulate : (currentAggregateValue, newValue) ->
    return currentAggregateValue + newValue

  offset : (currentAggregateValue, oldValue) ->
    return currentAggregateValue - oldValue


class CountStat extends Stat

  id : "count_stat"

  defaultOutputName : "count"

  accumulate : (currentAggregateValue, newValue) ->
    return currentAggregateValue + 1

  offset : (currentAggregateValue, oldValue) ->
    return currentAggregateValue - 1


class MeanStat extends Stat

  id : "mean_stat"

  defaultOutputName : "mean"

  accumulate : (currentAggregateValue, newValue, n) ->
    return ((currentAggregateValue * (n-1)) + newValue) / n

  offset : (currentAggregateValue, oldValue, n) ->
    return ((currentAggregateValue * (n+1)) - oldValue) / n


module.exports =
  Stat      : Stat
  SumStat   : SumStat
  CountStat : CountStat
  MeanStat  : MeanStat