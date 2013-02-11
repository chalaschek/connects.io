should  = require 'should'

Aggregator = require "../lib/aggregator"

{SlidingTimeWindow} = require "../lib/sliding-window"

SingletonWindow = require "../lib/singleton-window"

{SumStat, CountStat} = require "../lib/stat"

describe "Aggregator", ->
  describe "Default Configuration", ->
    agg = new Aggregator
      stats           : [ new SumStat("val"), new CountStat("val") ]

    it "should use a singleton window by default", () ->
      val = agg.window instanceof SingletonWindow
      val.should.eql true

    it "should emit aggregates upon new data by default", (done) ->
      agg.on "data:new", (data) ->
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
        done()

      agg.process
        val: 10

    it "should aggregate cumulative stats by default", (done) ->
      agg = new Aggregator
        stats           : [ new SumStat("val"), new CountStat("val") ]
      _c = 0
      agg.on "data:new", (data) ->
        if _c is 0
          should.exist data
          data.sum.should.eql 10
          data.count.should.eql 1
        else
          should.exist data
          data.sum.should.eql 20
          data.count.should.eql 2
          done()
        _c++


      agg.process
        val: 10
      agg.process
        val: 10

  it "should support a sliding time window", (done) ->
    agg = new Aggregator
      window          : new SlidingTimeWindow 100, 10
      stats           : [ new SumStat("val"), new CountStat("val") ]
      cumulative      : false
      #emitFrequency   : 100
  
    _c = 0
    agg.on "data:new", (data) ->
      if _c is 0
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
      else if _c is 1
        should.exist data
        data.sum.should.eql 11
        data.count.should.eql 2
      else if _c is 2
        should.exist data
        data.sum.should.eql 1
        data.count.should.eql 1
      else if _c is 3
        should.exist data
        data.sum.should.eql 0
        data.count.should.eql 0
        done()
      _c++

    agg.process
      val: 10

    setTimeout () ->
      agg.process
        val: 1
    , 20

  it "should emit aggregates on a user specified interval", (done) ->
    agg = new Aggregator
      stats           : [ new SumStat("val"), new CountStat("val") ]
      cumulative      : false
      emitFrequency   : 100
  
    _c = 0
    agg.on "data:new", (data) ->
      if _c is 0
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
      else if _c is 1
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
        done()
      _c++

    agg.process
      val: 10

  it "should support non-cumulative aggregates", (done) ->
    agg = new Aggregator
      stats           : [ new SumStat("val"), new CountStat("val") ]
      cumulative      : false
  
    _c = 0
    agg.on "data:new", (data) ->
      if _c is 0
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
      else if _c is 1
        should.exist data
        data.sum.should.eql 1
        data.count.should.eql 1
        done()
      _c++

    agg.process
      val: 10

    agg.process
      val: 1

  it "should support multiple stats", (done) ->
    agg = new Aggregator
      stats           : [ new SumStat("val"), new CountStat("val") ]
      cumulative      : false
  
    _c = 0
    agg.on "data:new", (data) ->
      if _c is 0
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
      else if _c is 1
        should.exist data
        data.sum.should.eql 1
        data.count.should.eql 1
        done()
      _c++

    agg.process
      val: 10

    agg.process
      val: 1

  it "should support grouping aggregate stats by a groupBy field", (done) ->
    agg = new Aggregator
      window          : new SlidingTimeWindow 100, 10
      stats           : [ new SumStat("val"), new CountStat("val") ]
      cumulative      : false
      groupBy         : "tag"
  
    _c = 0
    agg.on "data:new", (data) ->
      if _c is 0
        should.exist data?.a
        data.a.sum.should.eql 10
        data.a.count.should.eql 1
      else if _c is 1
        should.exist data?.a
        should.exist data?.b
        should.exist data
        data.a.sum.should.eql 10
        data.a.count.should.eql 1
        data.b.sum.should.eql 1
        data.b.count.should.eql 1
      else if _c is 2
        should.exist data?.a
        should.exist data?.b
        should.exist data
        data.a.sum.should.eql 11
        data.a.count.should.eql 2
        data.b.sum.should.eql 1
        data.b.count.should.eql 1
      else if _c is 3
        should.exist data?.a
        should.exist data?.b
        should.exist data
        data.a.sum.should.eql 1
        data.a.count.should.eql 1
        data.b.sum.should.eql 1
        data.b.count.should.eql 1
        done()
      _c++

    agg.process
      val: 10
      tag: "a"

    setTimeout () ->
      agg.process
        val: 1
        tag: "b"
    , 20

    setTimeout () ->
      agg.process
        val: 1
        tag: "a"
    , 50

