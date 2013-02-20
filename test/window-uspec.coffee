should  = require 'should'

Window = require "../lib/window"

SingletonWindow = require "../lib/singleton-window"

{SlidingTimeWindow} = require "../lib/sliding-window"

{MemoryStore} = require "../lib/store"

describe "Window", ->

  it "should use a memory store by default", ->
    window = new Window()
    val = window.store instanceof MemoryStore
    val.should.eql true

  it "should emit data", (done) ->
    window = new Window()
    window.on "data:new", (data) ->
      should.exist data?.key
      data.key.should.eql "test"
      done()

    window.emit "data:new",
      key: "test"


  describe "Singleton Window", ->
    it "should be able to process new data", ->
      singletonWindow = new SingletonWindow()
      singletonWindow.process
        val: 1

    it "should trigger push event", (done) ->
      singletonWindow = new SingletonWindow()
      singletonWindow.on "data:push", (elements) ->
        should.exist elements
        elements.length.should.eql 1
        elements[0].val.should.eql 1
        done()

      singletonWindow.process
        val: 1

    it "should trigger pop event", (done) ->
      singletonWindow = new SingletonWindow()
      
      singletonWindow.process
        val: 1

      singletonWindow.on "data:pop", (elements) ->
        should.exist elements
        elements.length.should.eql 1
        elements[0].val.should.eql 1
        done()

      singletonWindow.process
        val: 2


    it "should contain one element", (done) ->
      singletonWindow = new SingletonWindow()
      singletonWindow.process
        val: 2

      _c = 0
      cb = () => if ++_c is 2 then done()

      singletonWindow.on "data:pop", (elements) ->
        should.exist elements
        elements.length.should.eql 1
        elements[0].val.should.eql 2
        cb()

      singletonWindow.on "data:push", (elements) ->
        should.exist elements
        elements.length.should.eql 1
        elements[0].val.should.eql 1
        cb()

      singletonWindow.process
        val: 1




  describe "Sliding Time Window", ->
    it "should be able to process new data", ->
      slidingTimeWindow = new SlidingTimeWindow()
      slidingTimeWindow.process
        val: 1

    it "should trigger push event", (done) ->
      slidingTimeWindow = new SlidingTimeWindow 1000

      slidingTimeWindow.on "data:push", (elements) ->
        should.exist elements
        elements.length.should.eql 1
        elements[0].val.should.eql 1
        done()

      slidingTimeWindow.process
        val: 1

    it "should trigger pop event", (done) ->
      slidingTimeWindow = new SlidingTimeWindow 1

      slidingTimeWindow.on "data:pop", (elements) ->
        should.exist elements
        elements.length.should.eql 1
        elements[0].val.should.eql 2
        done()

      slidingTimeWindow.process
        val: 2


    it "should buffer data during the time window", (done) ->
      slidingTimeWindow = new SlidingTimeWindow 100

      t = Date.now()

      slidingTimeWindow.on "data:pop", (elements) ->
        if Date.now() - t < 100 then throw new Error "Data popped too early"
        if not popped
          popped = true
          done()

      slidingTimeWindow.on "data:push", (elements) ->
        should.exist elements
        elements.length.should.eql 1

      slidingTimeWindow.process
        val: 1

      slidingTimeWindow.process
        val: 2


    it "should purge data after time has expired", (done) ->
      slidingTimeWindow = new SlidingTimeWindow 100, 10

      t = Date.now()

      slidingTimeWindow.process
        val: 2

      setTimeout () ->
        slidingTimeWindow.process
          val: 1
      , 30

      slidingTimeWindow.on "data:pop", (elements) ->
        diff = Date.now() - t
        if diff < 130
          elements.length.should.eql 1
          elements[0].val.should.eql 2
        else
          elements.length.should.eql 1
          elements[0].val.should.eql 1
          done()
