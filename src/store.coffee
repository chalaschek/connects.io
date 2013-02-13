
class Store

  get : (key, callback) -> throw new Error "Method must be implemented"

  put : (key, value, callback) -> throw new Error "Method must be implemented"

  delete : (key, callback) -> throw new Error "Method must be implemented"


class MemoryStore extends Store
  constructor : () ->
    @_store = {}

  get : (key, callback) -> return callback null, @_store[key]

  put : (key, value, callback) ->
    @_store[key] = value
    callback()

  delete : (key, callback) ->
    delete @_store[key]
    callback()

module.exports =
  Store         : Store
  MemoryStore   : MemoryStore