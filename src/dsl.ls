# require "harmony-reflect"

var global

if not exports? 
  global := window
else 
  require "harmony-reflect" 
  global := exports 
   
notDef = (it) -> typeof it is "undefined"

isNormalMethod = (target, name) ->
  typeof (target[name]) is "function" and name isnt "__undefinedMethod__"

getMethods = 
    get: (target, name, receiver) ->

          var method

          if isNormalMethod(target, name) 
            method:= -> target[name].apply(target, arguments)

          else if notDef target[name]

            if notDef target.__undefinedMethod__ 

              target.__undefinedMethod__ = (name) ->
                console.log "called function [" + name + "] that does not exist"

            method:= ->
              newArguments = [name] +++ [ arg for arg in arguments ]
              target["__undefinedMethod__"].apply(target, newArguments)

          else
            method:= Reflect.get(target, name, arguments)

          method
          
methods = 
    construct: (target, argArray) ->
      Proxy Reflect.construct(target, argArray), getMethods         

global.safeObject = (f) ->

  retObject = Proxy(f, methods)

  retObject::__undefinedMethod__ = ->
    myName = arguments[0]
    console.log "Called an undefined method: " + myName
    undefined

  retObject
