(function(){
  var global, __s, __u, __q, __r, toLowerCase, debug, dbg, module, slice$ = [].slice;
  if (typeof exports == 'undefined' || exports === null) {
    global = window;
    __s = safeObject;
    __u = _;
    __q = Q;
  } else {
    __u = require("underscore");
    __r = require("harmony-reflect");
    __q = require("q");
    __s = require("./dsl").safeObject;
    global = exports;
  }
  toLowerCase = function(x, c){
    return x.charAt(0).toLowerCase() + x.slice(1);
  };
  debug = false;
  dbg = function(){
    if (debug) {
      return console.log(arguments);
    }
  };
  module = function(){
    var scope, safeClass, customMethods, init, addCustomMethod, bindScope, getScope, createNewMonad, fire, iface;
    init = function(s){
      scope = {};
      if (s != null) {
        scope = s;
      }
      customMethods = {};
      safeClass = __s(function(){});
      safeClass.prototype.__undefinedMethod__ = function(){
        var method, margs, cb;
        method = arguments[0];
        margs = slice$.call(arguments, 1);
        cb = (function(){
          switch (method) {
          case '_':
            return function(r){
              return margs[0].apply(this, [r]);
            };
          case '_forEach':
            return function(r){
              var x;
              return __q.all((function(){
                var i$, ref$, len$, results$ = [];
                for (i$ = 0, len$ = (ref$ = r).length; i$ < len$; ++i$) {
                  x = ref$[i$];
                  results$.push(margs[0].apply(this, [x]));
                }
                return results$;
              }.call(this)));
            };
          default:
            return function(r){
              var args, isNode, mm, isOnlySequential, isSeqNode, isIseqNode, __l, __f, __p, __d, __cb, prs;
              if (scope[method] != null) {
                args = [r].concat(margs);
                dbg("[chained]: invoking `" + method + "` with: ", args);
                return scope[method].apply(this, args);
              }
              isNode = method.match(/^n(\w+)/);
              if (isNode != null) {
                args = [r].concat(margs);
                mm = toLowerCase(isNode[1]);
                if (scope[mm] != null) {
                  dbg("[chained: ] invoking node function", mm, " with: ", args);
                  return __q.nfapply(scope[mm].bind(this), args);
                }
              }
              isOnlySequential = method.match(/^then(\w+)/);
              if (isOnlySequential != null) {
                mm = toLowerCase(isOnlySequential[1]);
                if (scope[mm] != null) {
                  dbg("[chained: ] invoking sequentially ", mm, " with: ", margs);
                  return scope[mm].apply(this, margs);
                }
              }
              isSeqNode = method.match(/^nThen(\w+)/);
              if (isSeqNode != null) {
                mm = toLowerCase(isSeqNode[1]);
                if (scope[mm] != null) {
                  dbg("[chaind: ] invoking sequentially node function ", mm, " with: ", margs);
                  return __q.nfapply(scope[mm].bind(this), margs);
                }
              }
              isIseqNode = method.match(/^ndThen(\w+)/);
              if (isIseqNode != null) {
                mm = toLowerCase(isIseqNode[1]);
                if (scope[mm] != null) {
                  dbg("[chained: ] invoking sequentially node function with inverse pars", mm, " with: ", margs);
                  __l = margs.length;
                  __f = margs[__l - 1];
                  __p = slice$.call(margs, 0, (__l - 2) + 1 || 9e9);
                  __d = __q.defer();
                  __cb = __d.makeNodeResolver();
                  prs = [__f].concat([__cb], __p);
                  scope[mm].apply(this, prs);
                  return __d.promise;
                }
              }
              dbg("While trying to invoke " + method);
              dbg("I've found: -> " + (scope[method] != null));
              dbg(scope);
              if (scope[method] == null) {
                throw method + " does'nt exist";
              }
            };
          }
        }());
        return createNewMonad(this.promise, cb);
      };
      return this;
    };
    addCustomMethod = function(name, f){
      return customMethods[name] = f;
    };
    bindScope = function(it){
      scope = __u.extend(scope, it);
      return this;
    };
    getScope = function(){
      return scope;
    };
    createNewMonad = function(promise, okCb, failCb){
      var s;
      s = new safeClass();
      s.promise = promise.then(okCb, failCb);
      s = __u.extend(s, customMethods);
      return s;
    };
    fire = function(v){
      var s;
      s = new safeClass();
      s = __u.extend(s, customMethods);
      s.d = __q.defer();
      s.promise = s.d.promise;
      s.d.resolve(v);
      return s;
    };
    iface = {
      init: init,
      addCustomMethod: addCustomMethod,
      bindScope: bindScope,
      using: bindScope,
      _: fire,
      getScope: getScope,
      createNewMonad: createNewMonad
    };
    return iface;
  };
  global.chain = module();
  global.C = module();
}).call(this);
