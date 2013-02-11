should  = require 'should'

Spout = require "../lib/spout"

describe "Spout", ->

  it "should emit data", (done) ->
    spout = new Spout()
    spout.on "data:new", (data) ->
      should.exist data?.key
      data.key.should.eql "test"
      done()

    spout.emit "data:new",
      key: "test"
