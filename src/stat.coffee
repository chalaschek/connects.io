class Stat

  id : "stat_interface"

  defaultOutputName : "stat_name"

  constructor : (@aggregateField, @outputName=@defaultOutputName) ->
    return new Error "Aggregate field must be specified" if not @aggregateField

  accumulate : (currentAggregateValue, newValue) -> return new Error "Method must be implemented"

  offset : (currentAggregateValue, oldValue) -> return new Error "Method must be implemented"



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



module.exports =
  Stat      : Stat
  SumStat   : SumStat
  CountStat : CountStat