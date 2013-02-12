should    = require 'should'

Spout     = require "../lib/spout"

Topology    = require "../lib/topology"

Aggregator    = require "../lib/aggregator"

{SumStat, CountStat}    = require "../lib/stat"

describe "Topology", ->

  it "should be able to create a stream", (done) ->
    spout = new Spout()
    topology = new Topology()
    stream = topology.stream spout, "stream1"
    stream.sink (data) ->
      should.exist data
      data.val.should.eql 1
      done()

    spout.emit "data:new",
      val : 1

  it "be able to lookup a stream by id", (done) ->
    spout = new Spout()
    topology = new Topology()
    topology.stream spout, "stream1"

    stream = topology.get "stream1"
    stream.sink (data) ->
      should.exist data
      data.val.should.eql 1
      done()
    spout.emit "data:new",
      val : 1


  it "be able to lookup nested streams using inject", (done) ->
    spout = new Spout()
    topology = new Topology()
    topology.stream(spout, "stream1")
            .inject( (data, cb) ->
              return cb null, {name: "test"}
            , "injecter")

    stream = topology.get "injecter"
    stream.sink (data) ->
      should.exist data
      data.val.should.eql 1
      data.name.should.eql "test"
      done()

    spout.emit "data:new",
      val : 1


  it "be able to lookup nested streams using project", (done) ->
    spout = new Spout()
    topology = new Topology()
    topology.stream(spout, "stream1")
            .project( (data, cb) ->
              return cb null, {id: data.val}
            , "projecter")

    stream = topology.get "projecter"
    stream.sink (data) ->
      should.exist data
      data.id.should.eql 1
      done()

    spout.emit "data:new",
      val : 1

  it "be able to lookup nested streams using filter", (done) ->
    spout = new Spout()
    topology = new Topology()
    topology.stream(spout, "stream1")
            .filter( (data, cb) ->
              if data.val is 1 then return cb()
              return cb null, data
            , "filter")

    stream = topology.get "filter"
    stream.sink (data) ->
      should.exist data
      data.val.should.eql 2
      done()

    spout.emit "data:new",
      val : 1

    spout.emit "data:new",
      val : 2


  it "be able to lookup nested streams using aggregates", (done) ->
    spout = new Spout()
    topology = new Topology()
    topology.stream(spout, "stream1")
            .aggregate( new Aggregator(
              stats : [ new SumStat("val"), new CountStat("val") ]
            ), "agger")

    stream = topology.get "agger"
    stream.sink (data) ->
      console.log data
      should.exist data
      data.sum.should.eql 1
      done()

    spout.emit "data:new",
      val : 1