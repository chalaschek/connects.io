Connect = require './connect'

class Stream extends Connect

  constructor : (stream) ->
    super stream

  process : (data) ->
    @emit "data:new", data

module.exports = Stream