{EventEmitter}  = require 'events'

class Worker extends EventEmitter

  process : (data) -> return new Error "Workers must implement process method"

module.exports = Worker