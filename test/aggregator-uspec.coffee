should  = require 'should'

Aggregator = require "../lib/aggregator"

{SlidingTimeWindow} = require "../lib/sliding-window"

SingletonWindow = require "../lib/singleton-window"

{SumStat, CountStat, MeanStat} = require "../lib/stat"

describe "Aggregator", ->

  describe "Default Configuration", ->

    it "should use a singleton window", () ->
      agg = new Aggregator()
      val = agg.window instanceof SingletonWindow
      val.should.eql true

    it "should be cumuluative", () ->
      agg = new Aggregator()
      agg.cumulative.should.eql true


    it "should emit aggregates upon new data", (done) ->
      agg = new Aggregator
        stats : [ new SumStat({aggregateField: "val"}) ]
      agg.on "data:new", (data) ->
        should.exist data
        data.sum.should.eql 10
        done()

      agg.process
        val: 10

    it "should support multiple stats", (done) ->
      agg = new Aggregator
        stats : [ new SumStat({aggregateField: "val"}), new CountStat({aggregateField: "val"}) ]
      agg.on "data:new", (data) ->
        should.exist data
        data.sum.should.eql 10
        data.count.should.eql 1
        done()

      agg.process
        val: 10


  describe "Sliding Time Window", ->

    it "should support cumulative window", (done) ->
      agg = new Aggregator
        window     : new SlidingTimeWindow 100, 10
        stats      : [ new SumStat({aggregateField: "val"}) ]

      _c = 0
      agg.on "data:new", (data) ->
        if _c is 0
          should.exist data
          data.sum.should.eql 10
        else if _c is 1
          should.exist data
          data.sum.should.eql 11
          done()
        _c++

      agg.process
        val: 10

      setTimeout () ->
        agg.process
          val: 1
      , 20



    it "should support non-cumulative window", (done) ->
      agg = new Aggregator
        window     : new SlidingTimeWindow 10, 10
        stats      : [ new SumStat({aggregateField: "val"}) ]
        cumulative: false

      _c = 0
      agg.on "data:new", (data) ->
        if _c is 0
          should.exist data
          data.sum.should.eql 10
        else if _c is 1
          should.exist data
          data.sum.should.eql 0
        else if _c is 2
          should.exist data
          data.sum.should.eql 1
          done()
        _c++

      agg.process
        val: 10

      setTimeout () ->
        agg.process
          val: 1
      , 20


  describe "Singleton Window", ->

    it "should support a cumulative window", (done) ->
      agg = new Aggregator
        stats      : [ new CountStat({aggregateField: "val"}) ]

      _c = 0
      agg.on "data:new", (data) ->
        if _c is 0
          should.exist data
          data.count.should.eql 1
        else if _c is 1
          should.exist data
          data.count.should.eql 2
          done()
        _c++

      agg.process
        val: 10

      setTimeout () ->
        agg.process
          val: 1
      , 20


    it "should support a non-cumulative window", (done) ->
      agg = new Aggregator
        stats      : [ new CountStat({aggregateField: "val"}) ]
        cumulative: false

      _c = 0
      agg.on "data:new", (data) ->
        if _c is 0
          should.exist data
          data.count.should.eql 1
        else if _c is 1
          should.exist data
          data.count.should.eql 1
          done()
        _c++

      agg.process
        val: 10

      setTimeout () ->
        agg.process
          val: 1
      , 20
