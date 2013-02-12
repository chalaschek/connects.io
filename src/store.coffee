
class Store

  get : (key) -> throw new Error "Method must be implemented"

  put : (key, value) -> throw new Error "Method must be implemented"


class MemoryStore extends Store
  constructor : () ->
    @_store = {}

  get : (key) -> return @_store[key]

  put : (key, value) -> @_store[key] = value

  delete : (key) -> delete @_store[key]

module.exports =
  Store         : Store
  MemoryStore   : MemoryStore