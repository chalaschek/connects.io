class Stat

  id : "stat_interface"

  defaultOutputName : "stat_name"

  constructor : (@aggregateField, @outputName=@defaultOutputName) ->
    return new Error "Aggregate field must be specified" if not @aggregateField

  accumulate : (currentAggregateValue, newValue) -> return new Error "Method must be implemented"

  offset : (currentAggregateValue, oldValue) -> return new Error "Method must be implemented"

module.exports = Stat