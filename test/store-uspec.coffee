should  = require 'should'

{MemoryStore} = require "../lib/store"

describe "Store", ->

  describe "Memory Store", ->

    store = new MemoryStore()

    it "should put data", (done) ->
      store.put "key", "value", () ->
        store.get "key", (error, value) ->
          value.should.eql "value"
          done()

    it "should get data", (done) ->
      store.get "key", (error, value) ->
        value.should.eql "value"
        done()


    it "should delete data", (done) ->
      store.delete "key", (error) ->
        store.get "key", (error, value) ->
          should.not.exist value
          done()
