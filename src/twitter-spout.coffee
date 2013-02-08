Spout = require "./spout"

Twit        = require 'twit'


class TwitterSpout extends Spout

  constructor: (twitterConfig) ->
    super()

    console.log twitterConfig

    @_twitter = new Twit twitterConfig

    console.log "Connecting to Twitter"

    #@_stream = @_twitter.stream 'statuses/filter',
    #  track : ["#rice", "#lol"].join ","
    @_stream = @_twitter.stream 'statuses/sample'

    @_stream.on 'tweet', (tweet) =>
     @emit "event:new", tweet

    @_stream.on 'warning', () => console.log "warning"

    @_stream.on 'connect', (response) =>
      console.log "connected"

    @_stream.on 'disconnect', (response) =>
      console.log response
      console.log "disconnect"

    @_stream.on 'limit', (response) =>
      console.log response
      console.log "limit"

    @_stream.on 'reconnect', (response) =>
      console.log response
      console.log "reconnect"

    @_stream.on 'disconnect', (response) =>
      console.log response
      console.log "disconnect"

    @_stream.on 'disconnect', (response) =>
      console.log response
      console.log "disconnect"
module.exports = TwitterSpout