class ProjectConnect extends require './connect'

  constructor : (@stream, @projectFn) ->
    super @stream

  execute : (data) -> return @projectFn data

module.exports = ProjectConnect