should  = require 'should'

{MemoryStore} = require "../lib/store"

{Stat, SumStat, CountStat, MeanStat} = require "../lib/stat"

describe "Stats", ->
  _name = "customOutputAttribute"

  it "should support custom output field names", ->
    stat = new Stat {aggregateField: "id", outputName: _name}
    stat.outputName.should.eql _name

  it "should use a memory store by default", ->
    stat = new Stat {aggregateField: "id", outputName: _name}
    val = stat.store instanceof MemoryStore


  describe "Sum Stats", ->
    it "should add stats when accumulated", (done) ->
      stat = new SumStat {aggregateField: "id", outputName: _name}
      stat.accumulate {id: 10}, (error, val) ->
        val[_name].should.equal 10
        stat.accumulate {id: 10}, (error, val) ->
          val[_name].should.equal 20
          done()

    it "should substract stats when offset", (done) ->
      stat = new SumStat {aggregateField: "id", outputName: _name}
      stat.accumulate {id: 10}, (error, val) ->
        val[_name].should.equal 10
        stat.offset {id: 10}, (error, val) ->
          val[_name].should.equal 0
          done()

    it "should support grouping aggregate stats by a groupBy field", (done) ->
      stat = new SumStat {aggregateField: "id", outputName: _name, groupBy: "group"}
      stat.accumulate {id: 10, group: "a"}, (error, val) ->
        val.a[_name].should.equal 10
        stat.accumulate {id: 10, group: "a"}, (error, val) ->
          val.a[_name].should.equal 20
          done()


  describe "Count Stats", ->
    it "should increment counter when accumulated", (done) ->
      stat = new CountStat {aggregateField: "id", outputName: _name}
      stat.accumulate {id: 10}, (error, val) ->
        val[_name].should.equal 1
        stat.accumulate {id: 10}, (error, val) ->
          val[_name].should.equal 2
          done()


    it "should descrement when offset", (done) ->
      stat = new CountStat {aggregateField: "id", outputName: _name}
      stat.accumulate {id: 10}, (error, val) ->
        val[_name].should.equal 1
        stat.offset {id: 10}, (error, val) ->
          val[_name].should.equal 0
          done()

    it "should support grouping aggregate stats by a groupBy field", (done) ->
      stat = new CountStat {aggregateField: "id", outputName: _name, groupBy: "group"}
      stat.accumulate {id: 10, group: "a"}, (error, val) ->
        val.a[_name].should.equal 1
        stat.accumulate {id: 10, group: "a"}, (error, val) ->
          val.a[_name].should.equal 2
          done()

  
  describe "Mean Stats", ->
    it "should update the mean when a number is added", (done) ->
      stat = new MeanStat {aggregateField: "id", outputName: _name}
      stat.accumulate {id: 10}, (error, val) ->
        val[_name].should.equal 10
        stat.accumulate {id: 0}, (error, val) ->
          val[_name].should.equal 5
          done()



    it "should update the mean when a number is removed", (done) ->
      stat = new MeanStat {aggregateField: "id", outputName: _name}
      stat.accumulate {id: 10}, (error, val) ->
        val[_name].should.equal 10
        stat.offset {id: 10}, (error, val) ->
          val[_name].should.equal 0
          done()

    it "should support grouping aggregate stats by a groupBy field", (done) ->
      stat = new MeanStat {aggregateField: "id", outputName: _name, groupBy: "group"}
      stat.accumulate {id: 10, group: "a"}, (error, val) ->
        val.a[_name].should.equal 10
        stat.accumulate {id: 20, group: "a"}, (error, val) ->
          val.a[_name].should.equal 15
          done()
