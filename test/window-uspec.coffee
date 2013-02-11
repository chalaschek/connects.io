should  = require 'should'

Window = require "../lib/window"

SingletonWindow = require "../lib/singleton-window"

{SlidingTimeWindow} = require "../lib/sliding-window"

describe "Window", ->

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


    it "should contain one element", () ->
      singletonWindow = new SingletonWindow()
      singletonWindow.process
        val: 2

      singletonWindow.events().length.should.eql 1
      singletonWindow.events()[0].val.should.eql 2




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


    it "should buffer data during time window", () ->
      slidingTimeWindow = new SlidingTimeWindow 100

      slidingTimeWindow.process
        val: 1

      slidingTimeWindow.process
        val: 2

      events = slidingTimeWindow.events()
      events.length.should.eql 2
      events[0].val.should.eql 1



    it "should purge data after time has expired", (done) ->
      slidingTimeWindow = new SlidingTimeWindow 100, 50

      slidingTimeWindow.process
        val: 2

      setTimeout () ->
        slidingTimeWindow.process
          val: 1
      , 30

      setTimeout () ->
        events = slidingTimeWindow.events()
        events.length.should.eql 1
        events[0].val.should.eql 1
        done()
      , 120
