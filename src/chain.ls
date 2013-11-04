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
                  args = [r] +++ margs 
                  throw "#method does'nt exist" if not scope[method]?
                  return scope[method].apply(@, args)

          return create-new-monad(@promise, cb)  

    return this

  add-custom-method = (name, f) ->
    customMethods[name] = f

  bind-scope = ->
    scope := __u.extend(scope, it)

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