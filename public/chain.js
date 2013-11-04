(function(){
  var global, __s, __u, __q, __r, module, slice$ = [].slice;
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
              var args;
              args = [r].concat(margs);
              if (scope[method] == null) {
                throw method + " does'nt exist";
              }
              return scope[method].apply(this, args);
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
      return scope = __u.extend(scope, it);
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
