Connect = require './connect'

class Stream extends Connect

  constructor : (stream, id, topology) ->
    super stream, null, id, topology

  process : (data) -> @_emit data

module.exports = Stream