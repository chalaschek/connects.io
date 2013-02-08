###
{Connect}  = require './connect'

console.log Connect

class FilterConnect extends Connect

  constructor : (@stream, @filterFn) ->
    super @stream

  execute : (data) -> return @filterFn data

module.exports = FilterConnect
###