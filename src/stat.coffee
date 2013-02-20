{EventEmitter}  = require 'events'
uuid            = require './uuid'
{MemoryStore}   = require './store'
_               = require 'underscore'
async           = require 'async'

class Stat extends EventEmitter

  defaultOutputName : "stat_name"

  constructor : (config) ->
    # set configs
    {@aggregateField, @outputName, @store, @groupBy} = config
    # default output name if needed
    @outputName = @defaultOutputName unless @outputName
    # default to memory store
    @store = new MemoryStore() unless @store

    throw new Error "Aggregate field must be specified" if not @aggregateField

  _groups : (element) ->
    # if not field to group by then ignore
    if not @groupBy or not element?[@groupBy] then return
    # get groups
    groups = element[@groupBy]
    # convert to array if needed
    if not (groups instanceof Array)
      groups = [groups]
    return groups

  _values : (elements) ->
    values = if @groupBy then {} else []
    for data in elements
      if data[@aggregateField] is null then continue
      val = data[@aggregateField]
      groups = @_groups data
      if groups
        for group in groups
          vals = values[group]
          if not vals
            values[group] = vals = []
          vals.push val
      else
        values.push val
    return values

  _update : (key, values, isAccumulate, callback) -> throw new Error "Method must be implemented"

  accumulate : (elements, callback) ->
    if not(elements instanceof Array) then elements = [elements]
    values = @_values elements
    if values instanceof Array
      @_update @_key, values, true, (error, value) =>
        result = {}
        result[@outputName] = value
        callback error, result
    else
      groups = _.keys values
      result = {}
      async.forEach groups, (group, cb) =>
        @_update "#{group}:#{@_key}", values[group], true, (error, value) =>
          _r = {}
          _r[@outputName] = value
          result[group] = _r
          cb()
      , (error) =>
        callback error, result

  offset : (elements, callback) ->
    if not(elements instanceof Array) then elements = [elements]
    values = @_values elements

    if values instanceof Array
      @_update @_key, values, false, (error, value) =>
        result = {}
        result[@outputName] = value
        callback error, result
    else
      groups = _.keys values
      result = {}
      async.forEach groups, (group, cb) =>
        @_update "#{group}:#{@_key}", values[group], false, (error, value) =>
          _r = {}
          _r[@outputName] = value
          result[group] = _r
          cb()
      , (error) =>
        callback error, result



class SumStat extends Stat

  defaultOutputName : "sum"

  _key : "sum"

  _update : (key, values, isAccumulate, callback) ->
    @store.get key, (error, curr=0) =>
      if error then return callback error
      newValue = _.reduce values, ((memo, num) -> return memo+num), 0
      if isAccumulate then val = curr+newValue else val = curr-newValue
      @store.put key, val, (error) =>
        if error then return callback error
        callback null, val



class CountStat extends Stat

  defaultOutputName : "count"

  _key : "count"

  _update : (key, values, isAccumulate, callback) ->
    @store.get key, (error, curr=0) =>
      if error then return callback error
      newValue = values.length
      if isAccumulate then val = curr+newValue else val = curr-newValue
      @store.put key, val, (error) =>
        if error then return callback error
        callback null, val



class MeanStat extends Stat

  defaultOutputName : "mean"

  _key : "mean"

  _update : (key, values, isAccumulate, callback) ->
    @store.get key, (error, data={n: 0, mean: 0}) =>
      if error then return callback error
      newValue = _.reduce values, ((memo, num) -> return memo+num), 0
      n = values.length
      if isAccumulate
        data.mean = ((data.mean * (data.n)) + newValue) / (data.n+n)
        data.n+=n
      else
        if data.n-n is 0 then data.mean = 0 else data.mean = ((data.mean * (data.n)) - newValue) / (data.n-n)
        data.n-=n
      @store.put key, data, (error) =>
        if error then return callback error
        callback null, data.mean



module.exports =
  Stat      : Stat
  SumStat   : SumStat
  CountStat : CountStat
  MeanStat  : MeanStat