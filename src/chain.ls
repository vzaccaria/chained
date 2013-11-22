var global

if not exports? 
  global := window
  __s = safeObject
  __u = _ 
  __q = Q
else 
  __u = require("underscore")
  __r = require "harmony-reflect"
  __q = require("q")
  __s = require("./dsl").safeObject
  global := exports 

debug = false
        
to-lower-case = (x, c) ->
    x.char-at(0).to-lower-case() + x.slice(1)

dbg = -> if debug then console.log arguments

module = ->

  var scope 
  var safeClass
  var customMethods

  init = (s) -> 
    scope         := {}
    scope         := s if s?
    customMethods := {}
    safeClass     := __s(->)
    safeClass::__undefinedMethod__ = ->
          method = arguments[0]
          margs  = arguments[1 to ]

          cb = switch method 
               | '_'        => (r) -> margs[0].apply(@, [r])
               | '_forEach' => (r) -> __q.all([ margs[0].apply(@, [x]) for x in r ]) 
               | otherwise  => (r) ->


                  if scope[method]? 
                    args = [r] +++ margs 
                    dbg "[chained]: invoking `#method` with: ", args
                    return scope[method].apply(@, args)

                  is-node = method.match(/^n(\w+)/)

                  if is-node?
                    args = [r] +++ margs 
                    mm = to-lower-case is-node[1]
                    if scope[mm]?
                      dbg "[chained: ] invoking node function", mm, " with: ", args
                      return __q.nfapply(scope[mm].bind(@), args)

                  is-only-sequential = method.match(/^then(\w+)/)

                  if is-only-sequential?
                    mm = to-lower-case is-only-sequential[1]
                    if scope[mm]?
                      dbg "[chained: ] invoking sequentially ", mm, " with: ", margs
                      return scope[mm].apply(@, margs)

                  is-seq-node = method.match(/^nThen(\w+)/)

                  if is-seq-node?
                    mm = to-lower-case is-seq-node[1]
                    if scope[mm]?
                      dbg "[chaind: ] invoking sequentially node function ", mm, " with: ", margs
                      return __q.nfapply(scope[mm].bind(@), margs)

                  throw "#method does'nt exist" if not scope[method]?

          return create-new-monad(@promise, cb)  

    return this

  add-custom-method = (name, f) ->
    customMethods[name] = f

  bind-scope = ->
    scope := __u.extend(scope, it)
    return this

  get-scope = -> scope

  create-new-monad = (promise, ok-cb, fail-cb) ->
    s         = new safeClass()
    s.promise = promise.then(ok-cb, fail-cb)
    s         = __u.extend(s,customMethods)
    return s

  fire = (v) -> 
      s         = new safeClass()
      s         = __u.extend(s,customMethods)
      s.d       = __q.defer()
      s.promise = s.d.promise
      s.d.resolve(v)
      return s

  # Revealing module pattern           
  iface = { 
    init              : init
    add-custom-method : add-custom-method
    bind-scope        : bind-scope
    using             : bind-scope
    _                 : fire
    get-scope         : get-scope
    create-new-monad  : create-new-monad
  }

  return iface

global.chain = module()
global.C     = module()



# .then(->console.log "#it OK!")