###
{Connect}  = require './connect'

class InjectConnect extends Connect

  constructor : (@stream, @injectFn) ->
    super @stream

  execute : (data) -> return @injectFn data

module.exports = InjectConnect
###