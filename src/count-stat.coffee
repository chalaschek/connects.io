Stat  = require './stat'

class CountStat extends Stat

  id : "count_stat"

  defaultOutputName : "count"

  accumulate : (currentAggregateValue, newValue) ->
    return currentAggregateValue + 1

  offset : (currentAggregateValue, oldValue) ->
    return currentAggregateValue - 1

module.exports = CountStat