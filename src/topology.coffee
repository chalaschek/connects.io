{MemoryStore}       = require '../lib/store'
Stream              = require '../lib/stream'
uuid                = require '../lib/uuid'
class Topology

  constructor : () ->
    @_store = new MemoryStore()

  register : (id, stream) ->
    return if @_store[id] is stream
    if @_store[id] then throw new Error "Element with id #{id} already exists in topology"
    @_store[id] = stream

  deregister: (id) ->
    if not @_store[id] then throw new Error "Element with id #{id} does not exists in topology"
    @_store[id] = null

  get : (id) ->
    if not @_store[id] then throw new Error "Element with id #{id} does not exists in topology"
    return @_store[id]

  stream : (spout, outStreamId) ->
    if not spout then throw new Error "Spout required"
    if not outStreamId then throw new Error "Stream name required"
    return new Stream spout, outStreamId, @

module.exports = Topology