uuid          = require './uuid'
{MemoryStore} = require './store'


class Stat

  defaultOutputName : "stat_name"

  constructor : (config) ->
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

  accumulate : (newValue, callback) -> throw new Error "Method must be implemented"

  offset : (oldValue, callback) -> throw new Error "Method must be implemented"



class SumStat extends Stat

  defaultOutputName : "sum"

  constructor : (config) ->
    super config
    # init key
    @_key = "#{@_id}:sum"

  accumulate : (newValue, callback) ->
    @store.get @_key, (error, curr=0) =>
      return callback error if error
      val = curr + newValue
      @store.put @_key, val, (error) =>
        return callback error, val

  offset : (oldValue, callback) ->
    @store.get @_key, (error, curr=0) =>
      return callback error if error
      # if cumulative then do nothing
      # TODO: consider throwing an error here
      if @cumulative then return callback null, curr
      val = curr - oldValue
      @store.put @_key, val, (error) ->
        return callback error, val


class CountStat extends Stat

  defaultOutputName : "count"

  constructor : (config) ->
    super config
    # init key
    @_key = "#{@_id}:count"

  accumulate : (newValue, callback) ->
    @store.get @_key, (error, curr=0) =>
      return callback error if error
      val = curr + 1
      @store.put @_key, val, (error) =>
        return callback error, val

  offset : (oldValue, callback) ->
    @store.get @_key, (error, curr=0) =>
      return callback error if error
      # if cumulative then do nothing
      # TODO: consider throwing an error here
      if @cumulative then return callback null, curr
      val = curr - 1
      @store.put @_key, val, (error) ->
        return callback error, val


class MeanStat extends Stat

  defaultOutputName : "mean"

  constructor : (config) ->
    super config
    # init keys
    @_key = "#{@_id}:mean"

  accumulate : (newValue, callback) ->
    @store.get @_key, (error, data={n: 0, mean: 0}) =>
      return callback error if error
      data.mean = ((data.mean * (data.n)) + newValue) / (data.n+1)
      data.n++
      @store.put @_key, data, (error) =>
        return callback error, data.mean

  offset : (oldValue, callback) ->
    @store.get @_key, (error, data={n: 0, mean: 0}) =>
      return callback error if error
      if @cumulative then return callback null, data.mean
      # TODO: consider how to handle negative
      data.mean = ((data.mean * (data.n)) - oldValue) / (data.n-1)
      data.n--
      @store.put @_key, data, (error) =>
        return callback error, data.mean


module.exports =
  Stat      : Stat
  SumStat   : SumStat
  CountStat : CountStat
  MeanStat  : MeanStat