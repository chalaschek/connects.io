should  = require 'should'

{Stat, SumStat, CountStat} = require "../lib/stat"

describe "Stats", ->
  _name = "customOutputAttribute"

  it "should support custom output field names", ->
    stat = new Stat "id", _name
    stat.outputName.should.eql _name

  describe "Sum Stats", ->
    stat = new SumStat "id", _name

    it "should add when accumulated", ->
      val = stat.accumulate 0, 10
      val.should.equal 10

    it "should substract when offset", ->
      val = stat.offset 10, 10
      val.should.equal 0


  describe "Count Stats", ->
    stat = new CountStat "id", _name

    it "should increment counter when accumulated", ->
      val = stat.accumulate 0, 10
      val.should.equal 1

    it "should descrement when offset", ->
      val = stat.offset 10, 10
      val.should.equal 9
