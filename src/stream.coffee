Connect = require './connect'

class Stream extends Connect

  constructor : (stream) ->
    super stream

  process : (data) ->
    @emit "event:new", data

module.exports = Stream