(function(){
  var global, notDef, isNormalMethod, getMethods, methods;
  if (typeof exports == 'undefined' || exports === null) {
    global = window;
  } else {
    require("harmony-reflect");
    global = exports;
  }
  notDef = function(it){
    return typeof it === "undefined";
  };
  isNormalMethod = function(target, name){
    return typeof target[name] === "function" && name !== "__undefinedMethod__";
  };
  getMethods = {
    get: function(target, name, receiver){
      var method;
      if (isNormalMethod(target, name)) {
        method = function(){
          return target[name].apply(target, arguments);
        };
      } else if (notDef(target[name])) {
        if (notDef(target.__undefinedMethod__)) {
          target.__undefinedMethod__ = function(name){
            return console.log("called function [" + name + "] that does not exist");
          };
        }
        method = function(){
          var newArguments, arg;
          newArguments = [name].concat((function(args$){
            var i$, len$, results$ = [];
            for (i$ = 0, len$ = args$.length; i$ < len$; ++i$) {
              arg = args$[i$];
              results$.push(arg);
            }
            return results$;
          }(arguments)));
          return target["__undefinedMethod__"].apply(target, newArguments);
        };
      } else {
        method = Reflect.get(target, name, arguments);
      }
      return method;
    }
  };
  methods = {
    construct: function(target, argArray){
      return Proxy(Reflect.construct(target, argArray), getMethods);
    }
  };
  global.safeObject = function(f){
    var retObject;
    retObject = Proxy(f, methods);
    retObject.prototype.__undefinedMethod__ = function(){
      var myName;
      myName = arguments[0];
      console.log("Called an undefined method: " + myName);
      return void 8;
    };
    return retObject;
  };
}).call(this);
