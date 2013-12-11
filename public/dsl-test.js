(function(){
  var should, jQuery, fs, chain, ref$, init, _, bindScope, safeObject, safeClass, madeOf, c, slice$ = [].slice;
  require("harmony-reflect");
  should = require('should');
  jQuery = require('jQuery');
  fs = require('fs');
  ref$ = chain = require("./chain").chain, init = ref$.init, _ = ref$._, bindScope = ref$.bindScope;
  console.log(chain);
  safeObject = require("./dsl").safeObject;
  safeClass = safeObject(function(){});
  safeClass.prototype.__undefinedMethod__ = function(){
    var methodName, args, formattedArgs, a, retVal;
    methodName = arguments[0];
    args = slice$.call(arguments, 1);
    formattedArgs = (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = args).length; i$ < len$; ++i$) {
        a = ref$[i$];
        results$.push(a + "");
      }
      return results$;
    }()).join('');
    retVal = "<" + methodName + ">" + formattedArgs + "<\\" + methodName + ">";
    return retVal;
  };
  madeOf = function(it){
    return it();
  };
  c = new safeClass();
  describe('Missing method', function(empty){
    it('should invoke __undefinedMethod__', function(done){
      var doc;
      doc = c.html(madeOf(c.head), madeOf(c.body));
      doc.should.be.equal("<html><head><\\head><body><\\body><\\html>");
      return done();
    });
    return it('should read and write a new property', function(done){
      var doc;
      c.x = 33;
      doc = c.html(madeOf(c.head), madeOf(c.body));
      c.x.should.be.equal(33);
      return done();
    });
  });
  describe('Binding', function(empty){
    it('init should not be null', function(){
      return should.exist(init);
    });
    it('bindScope should not be null', function(){
      return should.exist(bindScope);
    });
    return it('should bind a scope correctly', function(done){
      var scope;
      scope = {
        add: function(x){
          return x + 1;
        }
      };
      chain.init().bindScope(scope);
      should.exist(chain.getScope().add);
      should.not.exist(chain.getScope().ad);
      return done();
    });
  });
  describe('Chained operations', function(empty){
    it('should evaluate a single, non promise function', function(done){
      return chain._(10).add().promise.then(function(it){
        it.should.be.equal(11);
        return done();
      });
    });
    it('should evaluate a single, non promise function', function(done){
      chain._(3).add().promise.then(function(it){
        return it.should.be.equal(4);
      });
      return chain._(10).add().promise.then(function(it){
        it.should.be.equal(11);
        return done();
      });
    });
    it('should evaluate a single, non promise function with parameters', function(done){
      var succ, fail;
      chain.bindScope({
        addX: function(x, y){
          return x + y;
        }
      });
      succ = function(it){
        it.should.be.equal(15);
        return done();
      };
      fail = function(it){
        console.log(it + "");
        return true.should.be['false'];
      };
      return chain._(10).addX(5).promise.then(succ, fail);
    });
    it('should fail when a method is not present in the scope', function(done){
      var this$ = this;
      chain.init();
      this.failed = false;
      this.succ = function(it){
        return it.should.be.equal(15);
      };
      this.fail = function(){
        return this$.failed = true;
      };
      this.checkFailure = function(){
        this$.failed.should.be.equal(true);
        return done();
      };
      return chain._(10).addX(5).promise.then(this.succ, this.fail).fin(this.checkFailure);
    });
    return it('should not fail when a method is present in the scope', function(done){
      var this$ = this;
      chain.init();
      chain.bindScope({
        addX: function(x, y){
          return x + y;
        }
      });
      this.failed = true;
      this.succ = function(it){
        it.should.be.equal(15);
        return this$.failed = false;
      };
      this.fail = function(){
        return this$.failed = true;
      };
      this.checkFailure = function(){
        this$.failed.should.be.equal(false);
        return done();
      };
      return chain._(10).addX(5).promise.then(this.succ, this.fail).fin(this.checkFailure);
    });
  });
  describe('Stream based invocations', function(empty){
    it('add two times to a number, by using variables', function(done){
      var scope, x, y, z;
      scope = {
        add: function(x){
          return x + 1;
        }
      };
      chain.init().bindScope(scope);
      x = chain._(3);
      y = x.add();
      return z = y.add().promise.then(function(it){
        it.should.be.equal(5);
        return done();
      });
    });
    it('add two times to a number, by using concatenation', function(done){
      var scope, x;
      scope = {
        add: function(x){
          return x + 1;
        }
      };
      chain.init().bindScope(scope);
      return x = chain._(3).add().add().add().promise.then(function(it){
        it.should.be.equal(6);
        return done();
      });
    });
    return it('add two times to a number, by using concatenation (using success)', function(done){
      var x;
      return x = chain._(3).add().add().add().promise.then(function(it){
        it.should.be.equal(6);
        return done();
      });
    });
  });
  describe('Plain sequential invocations', function(empty){
    return it('invokes the function without the return value of the previous function', function(done){
      var scope, x;
      scope = {
        add: function(x){
          return x + 1;
        }
      };
      chain.init().bindScope(scope);
      return x = chain._(3).thenAdd(10).thenAdd(10).promise.then(function(it){
        it.should.be.equal(11);
        return done();
      });
    });
  });
  describe('De-referencing', function(empty){
    it('_ should work also when dereferenced', function(done){
      var f;
      f = function(__){
        return __(3).add().add().add().promise.then(function(it){
          it.should.be.equal(6);
          return done();
        });
      };
      return f(chain._);
    });
    it('_ should work also when using a locally introduced function', function(done){
      var acc, f;
      acc = function(x){
        return x + 2;
      };
      f = function(__){
        return __(3).add()._(acc).add().promise.then(function(it){
          it.should.be.equal(7);
          return done();
        });
      };
      return f(chain._);
    });
    return it('_ should work also when using a variable with another chained computation', function(done){
      var acc, f;
      acc = function(x){
        return chain._(x).add().promise;
      };
      f = function(__){
        return __(3).add()._(acc).add().promise.then(function(it){
          it.should.be.equal(6);
          return done();
        }).fail(function(it){
          return console.log(it);
        });
      };
      return f(chain._);
    });
  });
  describe('forEach control', function(empty){
    return it('_forEach should apply a function to a coming vector', function(done){
      var acc;
      acc = function(x){
        return x + 2;
      };
      return chain._([1, 2])._forEach(acc).promise.then(function(it){
        it.should.be.eql([3, 4]);
        return done();
      });
    });
  });
  describe('Real world usage', function(empty){
    it('should not execute second function if first fails', function(done){
      chain.bindScope(jQuery);
      chain.bindScope({
        logit: function(x){
          return should.not.exist(x);
        }
      });
      return chain._('http://www.google.com').get().logit().promise.then(done).fail(function(){
        true.should.be.ok;
        return done();
      });
    });
    return it('should not execute second function if first fails - II', function(done){
      chain.bindScope(jQuery);
      chain.bindScope({
        logit: function(x){
          return should.not.exist(x);
        }
      });
      return chain._('http://www.google.com').get().logit().promise.fail(function(){
        true.should.be.ok;
        return done();
      });
    });
  });
  describe('Invoking node-styled functions', function(empty){
    it('should read an existing file', function(done){
      chain.init().bindScope(fs).bindScope(console);
      return chain._("./src/form.ls").nReadFile('utf-8').promise.then(function(){
        return done();
      });
    });
    it('should fail on error existing file', function(done){
      chain.init().bindScope(fs).bindScope(console);
      return chain._("./src/for.ls").nReadFile('utf-8').promise.fail(function(){
        return done();
      });
    });
    return it('should read an existing file with nThen', function(done){
      chain.init().bindScope(fs).bindScope(console);
      return chain._("./src/for.ls").nThenReadFile("./src/form.ls", 'utf-8').promise.then(function(){
        return done();
      });
    });
  });
  describe('Invoking phantomjs/style functions', function(empty){
    return it('wait for a specific timeout passed as a parameter', function(done){
      var myf, scope, intermediate;
      myf = function(f, cb, p){
        var tx;
        tx = function(){
          f();
          return cb(null, 'ok');
        };
        return setTimeout(tx, p);
      };
      scope = {
        time: myf
      };
      chain.init().bindScope(scope);
      return intermediate = chain._("").ndThenTime(3, function(){
        return done();
      });
    });
  });
}).call(this);
