Spout = require "./spout"

Twit        = require 'twit'


class TwitterSpout extends Spout

  constructor: (twitterConfig) ->
    @_count = 0

    super()

    @_twitter = new Twit twitterConfig

    console.log "Connecting to Twitter"

    @_stream = @_twitter.stream 'statuses/filter',
      track : ["#rice", "#lol"].join ","
    #@_stream = @_twitter.stream 'statuses/sample'

    @_stream.on 'tweet', (tweet) =>
      @_count++
      #console.log "tweet #{@_count}"
      @emit "data:new", tweet

module.exports = TwitterSpout