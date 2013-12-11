

require "harmony-reflect"
require! "should"
require! "jQuery"
require! "fs"
{ init, _, bindScope} = chain = require("./chain").chain

console.log chain 

# _ = chain._

safeObject = require("./dsl").safeObject

safeClass = safeObject(->)

safeClass::__undefinedMethod__ = ->
  methodName     = arguments[0]
  args           = arguments[1 to ]
  formatted-args = [ "#a" for a in args ] * ''
  retVal         = "<#methodName>#formatted-args<\\#methodName>"
  retVal

made-of = ->
    it()

c = new safeClass()

describe 'Missing method', (empty) ->
    it 'should invoke __undefinedMethod__',  (done) ->
      doc = c.html made-of(c.head), made-of(c.body)
      doc.should.be.equal("<html><head><\\head><body><\\body><\\html>")
      done()

    it 'should read and write a new property',  (done) ->
      c.x = 33 
      doc = c.html made-of(c.head), made-of(c.body)
      c.x.should.be.equal(33) 
      done()

describe 'Binding', (empty) ->
    it 'init should not be null', ->
        should.exist(init)

    it 'bindScope should not be null', ->
        should.exist(bindScope)

    it 'should bind a scope correctly', (done) ->
        scope = { add: (x) -> x+1 }

        chain.init().bindScope(scope)
        should.exist(chain.get-scope().add)
        should.not.exist(chain.get-scope().ad)
        done()

describe 'Chained operations', (empty) ->
    it 'should evaluate a single, non promise function', (done) ->

        chain._(10).add().promise.then -> 
            it.should.be.equal(11)
            done()

    it 'should evaluate a single, non promise function', (done) ->

        chain._(3).add().promise.then -> 
            # console.log it
            it.should.be.equal(4)

        chain._(10).add().promise.then -> 
            it.should.be.equal(11)
            done()

    it 'should evaluate a single, non promise function with parameters', (done) ->
        chain.bindScope({ addX: (x,y) -> x+y })

        succ = -> 
                  it.should.be.equal(15)
                  done()

        fail = -> 
                  console.log ("#it")
                  true.should.be.false

        chain._(10).addX(5).promise.then(succ, fail)

    it 'should fail when a method is not present in the scope', (done) ->
        # chain.bindScope({ addX: (x,y) -> x+y })
        chain.init()

        @failed = false

        @succ = ~> 
                  it.should.be.equal(15)

        @fail = ~> 
                  @failed = true

        @check-failure = ~>
            @failed.should.be.equal(true)
            done()

        chain._(10).addX(5).promise.then(@succ, @fail).fin(@check-failure)

    it 'should not fail when a method is present in the scope', (done) ->
        chain.init()
        chain.bindScope({ addX: (x,y) -> x+y })

        @failed = true

        @succ = ~> 
                  it.should.be.equal(15)
                  @failed = false

        @fail = ~> 
                  @failed = true

        @check-failure = ~>
            @failed.should.be.equal(false)
            done()

        chain._(10).addX(5).promise.then(@succ, @fail).fin(@check-failure)



describe 'Stream based invocations', (empty) ->
    it 'add two times to a number, by using variables', (done) ->
      scope = { add: (x) -> x+1 }
      chain.init().bindScope(scope)

      x = chain._(3)
      y = x.add()
      z = y.add().promise.then(-> it.should.be.equal(5); done())


    it 'add two times to a number, by using concatenation', (done) ->
      scope = { add: (x) -> x+1 }
      chain.init().bindScope(scope)

      x = chain._(3).add().add().add().promise.then(-> it.should.be.equal(6); done())

    it 'add two times to a number, by using concatenation (using success)', (done) ->
      # scope = { add: (x) -> x+1 }
      # chain.init().bindScope(scope)

      x = chain._(3).add().add().add().promise.then(-> it.should.be.equal(6); done())

describe 'Plain sequential invocations', (empty) ->
    it 'invokes the function without the return value of the previous function', (done) ->
      scope = { add: (x) -> x+1 }
      chain.init().bindScope(scope)
      x = chain._(3).thenAdd(10).thenAdd(10).promise.then( -> it.should.be.equal(11); done() )


describe 'De-referencing', (empty) ->
    it '_ should work also when dereferenced', (done) ->

        f = (__) ->
          __(3).add().add().add().promise.then(-> it.should.be.equal(6); done())

        f(chain._)

    it '_ should work also when using a locally introduced function', (done) ->

        acc = (x) -> x + 2

        f = (__) ->
          __(3).add()._(acc).add().promise.then(-> it.should.be.equal(7); done())

        f(chain._)

    it '_ should work also when using a variable with another chained computation', (done) ->

        acc = (x) -> 
          chain._(x).add().promise

        f = (__) ->
          __(3).add()._(acc).add().promise.then(-> it.should.be.equal(6); done()).fail(-> console.log it)

        f(chain._)

describe 'forEach control', (empty) ->
    it '_forEach should apply a function to a coming vector', (done) ->

      acc = (x) -> x + 2

      chain._([1,2])._forEach(acc).promise.then(-> it.should.be.eql([3,4]); done())


describe 'Real world usage', (empty) ->
    it 'should not execute second function if first fails', (done) ->

        chain.bindScope(jQuery)
        chain.bindScope({ logit: (x) -> should.not.exist(x) }) 

        chain._('http://www.google.com').get().logit().promise.then(done).fail(-> true.should.be.ok; done()) 

    it 'should not execute second function if first fails - II', (done) ->

        chain.bindScope(jQuery)
        chain.bindScope({ logit: (x) -> should.not.exist(x) }) 

        chain._('http://www.google.com').get().logit().promise.fail(-> true.should.be.ok; done()) 


describe 'Invoking node-styled functions', (empty) ->
    it 'should read an existing file', (done) ->
      chain.init().bindScope(fs).bindScope(console)
      chain._("./src/form.ls").nReadFile('utf-8').promise.then( -> done() )

    it 'should fail on error existing file', (done) ->
      chain.init().bindScope(fs).bindScope(console)
      chain._("./src/for.ls").nReadFile('utf-8').promise.fail( -> done() )

    it 'should read an existing file with nThen', (done) ->
      chain.init().bindScope(fs).bindScope(console)
      chain._("./src/for.ls").nThenReadFile("./src/form.ls", 'utf-8').promise.then( -> done() )

describe 'Invoking phantomjs/style functions', (empty) ->
    it 'wait for a specific timeout passed as a parameter', (done) ->

      myf = (f, cb, p) -> 
        tx = -> 
          f()
          cb(null, 'ok')

        set-timeout(tx,p)

      scope = { time: myf }

      chain.init().bindScope(scope)
      intermediate = chain._("").ndThenTime(3, -> done())
      # intermediate.promise.then(( -> done() ))




