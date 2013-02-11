should  = require 'should'

Spout   = require "../lib/spout"
Stream   = require "../lib/stream"
Connect = require "../lib/connect"
Aggregator = require "../lib/aggregator"
{SumStat, CountStat} = require "../lib/stat"


describe "Connect", ->
  it "should support filter", (done) ->
    spout = new Spout()
    stream = new Stream spout
    connect = stream.filter (data, cb) ->
      if data.keep then return cb null, data else return cb()

    connect.on "data:new", (data) ->
      should.exist data
      data.val.should.eql 10
      done()

    spout.emit "data:new",
      keep: false
      val: 1

    spout.emit "data:new",
      keep: true
      val: 10

  it "should support projects", (done) ->
    spout = new Spout()
    stream = new Stream spout
    connect = stream.project (data, cb) ->
      return cb null,
        val: data.val

    connect.on "data:new", (data) ->
      should.exist data
      data.val.should.eql 1
      should.not.exist data.name
      done()

    spout.emit "data:new",
      name: "test"
      val: 1

  it "should support injects", (done) ->
    spout = new Spout()
    stream = new Stream spout
    connect = stream.inject (data, cb) ->
      return cb null,
        name: "test"

    connect.on "data:new", (data) ->
      should.exist data
      data.val.should.eql 1
      should.exist data.name
      data.name.should.eql "test"
      done()

    spout.emit "data:new",
      val: 1

  it "should support aggregates", (done) ->
    spout = new Spout()
    stream = new Stream spout
    connect = stream.aggregate new Aggregator
      stats : [ new SumStat("val"), new CountStat("val") ]

    _c = 0
    connect.on "data:new", (data) ->
      should.exist data
      if _c is 0
        data.sum.should.eql 1
        data.count.should.eql 1
      else if _c is 1
        data.sum.should.eql 10
        data.count.should.eql 2
        done()
      _c++

    spout.emit "data:new",
      val: 1

    spout.emit "data:new",
      val: 9

  it "should support chaining connects", (done) ->
    spout = new Spout()
    connect = new Stream(spout)
          .aggregate( new Aggregator {stats : [ new SumStat("val"), new CountStat("val") ] } )
          .filter( (data, cb) ->
            if data.count > 1 then return cb null, data else return cb() )
          .project( (data, cb) ->
            return cb null, {val: data.count})
          .inject( ( data, cb)-> return cb null, {name: "test"} )

    connect.on "data:new", (data) ->
      should.exist data
      data.val.should.eql 2
      should.exist data.name
      data.name.should.eql "test"
      done()

    spout.emit "data:new",
      val: 1

    spout.emit "data:new",
      val: 10

  it "should support output sinks", (done) ->
    spout = new Spout()
    connect = new Stream(spout)
          .aggregate( new Aggregator {stats : [ new SumStat("val"), new CountStat("val") ] } )
          .filter( (data, cb) ->
            if data.count > 1 then return cb null, data else return cb() )
          .project( (data, cb) ->
            return cb null, {val: data.count})
          .inject( ( data, cb)-> return cb null, {name: "test"} )
          .sink (data) ->
            should.exist data
            data.val.should.eql 2
            should.exist data.name
            data.name.should.eql "test"
            done()


    spout.emit "data:new",
      val: 1

    spout.emit "data:new",
      val: 10


