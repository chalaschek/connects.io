Stat  = require './stat'

class SumStat extends Stat

  id : "sum_stat"

  defaultOutputName : "sum"

  accumulate : (currentAggregateValue, newValue) ->
    return currentAggregateValue + newValue

  offset : (currentAggregateValue, oldValue) ->
    return currentAggregateValue - oldValue

module.exports = SumStat