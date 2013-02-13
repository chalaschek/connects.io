should          = require 'should'

Worker          = require "../lib/worker"

FilterWorker    = require "../lib/filter-worker"

ProjectWorker   = require "../lib/project-worker"

InjectWorker    = require "../lib/inject-worker"

AggregateWorker = require "../lib/aggregate-worker"

Aggregator      = require "../lib/aggregator"

{SumStat, CountStat} = require "../lib/stat"

describe "Worker", ->

  it "should be able to emit data", (done) ->
    worker = new Worker()

    worker.on "data:new", (data) ->
      should.exist data?.key
      data.key.should.eql "test"
      done()

    worker.emit "data:new",
      key: "test"

  describe "Filter Worker", ->
    filterWorker = new FilterWorker (data, cb) ->
      should.exist data
      if data.keep then return cb null, data else return cb()

    it "should be able to process new data", ->
      filterWorker.process
        keep: false

    it "should filter data", (done) ->
      filterWorker.on "data:new", (data) ->
        should.exist data
        data.keep.should.eql true
        done()

      filterWorker.process
        keep: false

      filterWorker.process
        keep: true

  describe "Inject Worker", ->
    injectWorker = new InjectWorker (data, cb) ->
      should.exist data?.attr1
      should.exist data?.attr2
      return cb null,
        attr3: "attr3"
        attr4: "attr4"

    it "should be able to process new data", ->
      injectWorker.process
        attr1: "attr1"
        attr2: "attr2"

    it "should inject attributes", (done) ->
      injectWorker.on "data:new", (data) ->
        should.exist data?.attr1
        data.attr1.should.eql "attr1"
        should.exist data?.attr2
        data.attr2.should.eql "attr2"
        should.exist data?.attr3
        data.attr3.should.eql "attr3"
        should.exist data?.attr4
        data.attr4.should.eql "attr4"
        done()

      injectWorker.process
        attr1: "attr1"
        attr2: "attr2"


  describe "Project Worker", ->
    projectWorker = new ProjectWorker (data, cb) ->
      should.exist data?.attr1
      should.exist data?.attr2
      return cb null,
        attr1: data.attr1

    it "should be able to process new data", ->
      projectWorker.process
        attr1: "attr1"
        attr2: "attr2"

    it "should project attributes", (done) ->
      projectWorker.on "data:new", (data) ->
        should.exist data?.attr1
        data.attr1.should.eql "attr1"
        should.not.exist data?.attr2
        done()

      projectWorker.process
        attr1: "attr1"
        attr2: "attr2"


  describe "Aggregate Worker", ->
    aggregator = new Aggregator
      stats           : [ new SumStat({aggregateField: "val"}), new CountStat({aggregateField: "val"}) ]
      cumulative      : true
      emitFrequency   : 100

    aggregateWorker = new AggregateWorker aggregator

    it "should be able to process new data", ->
      aggregateWorker.process
        val: 0

    it "should invoke aggregator and emit aggregates", (done) ->
      _done = false
      aggregateWorker.on "data:new", (data) ->
        should.exist data?.sum
        data.sum.should.eql 10
        should.exist data?.count
        data.count.should.eql 2
        if not _done
          _done = true
          done()

      aggregateWorker.process
        val: 10


