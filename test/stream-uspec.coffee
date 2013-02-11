should    = require 'should'

Spout     = require "../lib/spout"

Stream    = require "../lib/stream"


describe "Stream", ->

  describe "when connected to a spout", ->
    spout = new Spout()

    it "should recreive data", (done) ->
      stream = new Stream spout

      stream.on "data:new", (data) ->
        should.exist data?.key
        data.key.should.eql "test"
        done()

      spout.emit "data:new",
        key: "test"

