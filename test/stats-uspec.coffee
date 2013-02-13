should  = require 'should'

{Stat, SumStat, CountStat, MeanStat} = require "../lib/stat"

describe "Stats", ->
  _name = "customOutputAttribute"

  it "should support custom output field names", ->
    stat = new Stat {aggregateField: "id", outputName: _name}
    stat.outputName.should.eql _name

  describe "Sum Stats", ->
    stat = new SumStat {aggregateField: "id", outputName: _name}

    it "should add when accumulated", (done) ->
      stat.accumulate 10, (error, val) ->
        val.should.equal 10
        done()

    it "should substract when offset", (done) ->
      stat.offset 10, (error, val) ->
        val.should.equal 0
        done()


  describe "Count Stats", ->
    stat = new CountStat {aggregateField: "id", outputName: _name}

    it "should increment counter when accumulated", (done) ->
      stat.accumulate 10, (error, val) ->
        val.should.equal 1
        done()

    it "should descrement when offset", (done) ->
      stat.offset 10, (error, val) ->
        val.should.equal 0
        done()

  
  describe "Mean Stats", ->
    stat = new MeanStat {aggregateField: "id", outputName: _name}

    it "should update the mean when a number is added", (done) ->
      stat.accumulate 10, (error, val) ->
        val.should.equal 10
        stat.accumulate 0, (error, val) ->
          val.should.equal 5
          done()



    it "should update the mean when a number is removed", (done) ->
      stat.offset 0, (error, val) ->
        val.should.equal 10
        done()