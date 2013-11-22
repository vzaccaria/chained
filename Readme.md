


### What is Chained
**Chained** is an experiment and a prototype library for Javascript. It is meant to show a concept and to provide some limited but useful functionality. All the examples below are written in Coffeescript (and I guess that this makes me a hippie, right?).

**Chained** allows to chain functions explicitly — both those that return promises and those who don't — without using `then`-based constructs.

For example, here's how you could create a chained computation that:

* downloads with jQuery's `get` a user's `npm` page 
* filters the links to his projects with underscore 
* prints the links 

(hover above the underlined elements for additional info)

    jQuery       = require('jQuery')
    underscore   = require('underscore')
    string       = require('underscore.string')
    linklib      = require('linklib')
    { using, _ } = require('./chain').chain.init()

    using(jQuery)
    using(underscore)
    using(string)
    using(console)
    using(linklib)

    getUser = (user) ->
          _("https://npmjs.org/~#{user}")
            .get()
            .extractLinks()
            .filter( -> /package/.test(arguments[0]) )
            .map( -> "https://npmjs.org#{arguments[0]}" )
            .log()

    getUser("vzaccaria")

Here, we have chained together promise-based functions (like `get` from `jQuery`) and normal functions with additional parameters (like `map` and `filter` from `underscore`). All  function invocations receive an implicit argument that is the value computed by the previous link in the chain.

The function defined in `getUser` implements a processing pipeline (à la *streaming*). It starts with the link to be retrieved by specifying it with `_()`:

    _("https://npmjs.org/~#{user}")

this value is then passed to `get()` of `jQuery`. **Chained** knows that `jQuery` has a `get` method since we introduced its scope with

    using(jQuery) 

at the beginning[^1].

The result of `get()` — i.e. the webpage — is sent to `extractLinks` (from `linklib`) when the associated promise is resolved.
The rest of the computation proceeds as you can intuitively imagine.

If an exception is thrown in any of the links of the processing chain then the following links are not executed, just as you would expect from promises.

We can add additional arguments (besides the implicit one) to method invocations; for example the `filter` function (from `underscore`) is invoked as:

    …
    .filter( -> /package/.test(arguments[0]) )
    …

where the *lambda* function is passed effectively as the second parameter to `underscore.filter` (the first being the implicit parameter).

So we nailed a few things here:

* We can chain promise-based functions and normal functions without distinction using the natural syntax of Javascript.
* We can use directly their names instead of using `then`.
* We can chain **any method** from an arbitrary number of modules, provided that the module is bound to **Chained** with the `using` clause.
* We don't modify dynamically the module that are imported. We don't change any prototype.
* The chain stops executing when one of the links throws an exception or a promise is rejected.
* We are not using any coffee-script mambo-jumbo for chaining; we can write with the same expressiveness in pure Javascript.

---

### Where's the catch?

We are exploiting ECMA6/harmony implementation of **introspection**. 
You need an ECMA6/harmony implementation, either in node (`node --harmony`) or in your browser (Firefox is ok at the moment) to make it work. 

---


### Does it work in the browser?

Yes, check out this example [Domain Specific Language for form validation](demo.html) directly built with Chained. **Warning: it needs a recent build of Firefox. In principle also a harmony-enabled Chrome should work, but I did not try it**.

---


### How to install it?

On node: 
    
    npm install chained

In the browser, download it from Github and include these files:

* `reflect.js`
* `dsl.js`, 
* `chain.js`

You should be good to go.

---


### Implementation

The idea for **Chained** came while tinkering with **domain specific languages**. DSLs provide the developer with the vocabulary of a problem domain to express a programmatic solution that could be understood by a *problem domain expert*[^2].

I will not cover all the general concepts of DSLs here. For an in depth overview, I'd suggest to look at these resources:  

* [Debasish Ghosh, "DSLs in Action"](http://www.amazon.com/DSLs-Action-Debasish-Ghosh/dp/1935182455) — Manning Publications Co.
* [Martin Fowler Website](http://martinfowler.com/books/dsl.html) (and [book](http://www.amazon.com/gp/product/0321712943?ie=UTF8&tag=martinfowlerc-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0321712943)) 
* [Writing Domain Specific Languages](http://docs.codehaus.org/display/GROOVY/Writing+Domain-Specific+Languages) — Groovy website. 
* [Validation DSL for Client-Server Applications](http://www.cas.mcmaster.ca/~carette/publications/FedorenkoThesis.pdf) — Vitalii Fedorenko Master Thesis
* [WebDSL](http://webdsl.org/home) 


**Internal DSLs** are built using the syntactic and semantic features of another language; they are used in the context of a broader application for which they address a narrow but important problem.

My quest was to find a way to implement a DSL in Javascript. Let's see what features are needed by a general purpose language like Javascript to support the definition of internal DSLs:

* Support for named arguments (or hashes) in function invocation (aka *Smart API*), e.g.:

        move(the: pen, on: theTable)

* Support for a *property/method missing exception* to implement method chaining:

        take('spaghetti').and().cookIt(at: 100C)

    here `and` is a non existing method of the return value `V` of `take('spaghetti')`. The missing exception handler will return the same value `V` so that `cookIt` could be called on it.

* (optional, but highly desirable) 

    - Reduced boilerplate code. 

    - Synthetic expression of closures (w/ implicit arguments).
     
    - Limited presence of parenthesis `{}` and `()`:
    
	        withObject chair, ->
	            move it, in: theLivingRoom

At some point, it became clear to me that DSLs' *method chaining* can be used to implicitly structure promise based chains. In fact, you could build a promise-chain by handling a sequence of method missing exceptions.

As a byproduct, it is straightforward to use the same technique to chain normal functions, without any exogenous construct like `then`.

#### The roadblocks

Javascript and its relatives (such as Coffee and LiveScript) have almost all the characteristics to build a sophisticated DSL. The only problem is that they lack of a **method missing exception**; at least until Harmony came out.

[Dylan Barrell already demonstrated](http://unobfuscated.blogspot.it/2012/06/creating-catchall-method-for-javascript.html) that with the new **reflection** API, it is possible to manage missing methods. His technique exploits the concept of **Proxies**. Think about a Proxy like a wrapper around your original object that is able to intercept calls to methods that are not defined. **Chained** is based on Dylan's work.


#### The basic idea

The basic idea goes as follows:

1. We create an object that can handle missing methods [through an appropriate mechanism](http://unobfuscated.blogspot.it/2012/06/creating-catchall-method-for-javascript.html). Let's call it `o`.

2. `o` contains a `promise` property. Whenever a method missing is invoked on `o`:

		o.m()
	
	we catch it and handle it with the following handler: 
	
		handleMethodMissing = (m) -> 
            this.promise = this.promise.then( (it) -> scope[m](it) )
            return this
		      

    now, note that:
    
    * we need a scope in which to look for `m`. In **Chained**, we use `using(module)` to specify/extend this scope.
    * `m` is called with the final value of the previous promise. 
    * even if `m` returns a new promise, this is perfectly fine since the `then` method is going to resolve the original `o.promise` accordingly.
    * we return `o`, so that we can repeat the same process by seemingly chaining methods that are effectively missing.

3. We need a way to fire the very first promise off. In **Chained**, we use the function `_()` both for creating `o` and to resolve the first promise of the chain with the value passed to it:

		_(v) = -> 
		     o = new methodMissingObject()
		     o.deferred = defer()
		     o.promise = o.deferred.promise
		     o.deferred.resolve(v)
		     return o
	     

### API

The API is pretty simple at the moment; however, I think it offers a good level of flexibility to be leveraged.

`chain.using(module)`
: Extends the scope within which all missing methods are searched for. You can include multiple modules:

            using(jQuery)
            using(underscore)


`o = chain._(value)` 
: returns a deferred object whose `promise` property will eventually be resolved to `value`. The object handles missing methods by chaining them using `Q`.

#### Deferred object methods and properties

Given the deferred object `o`, the following methods apply; remember that they return again a deferred object:

`o.foo(...)` 
: if `o` eventually resolves to `v`, this is essentially equivalent to building a *deferred* `foo(v, ...)`.   




`o._(foo)`
: specify a one shot function `foo` to be chained with the rest, without extending the scope with `using`.   




`o._forEach(bar)`
: if `o` will eventually resolve to an array, apply `bar` to each element; the combined promise is created with `Q.all`.



`o.promise`
: this is a Q promise corresponding to the deferred `o`. 

**New**:

`o.nFoo`
: as `o.foo` but treats `foo` as a node-style async function (i.e., callback are assumed to be in the form `(err, res) ->` ). Example: 

        using(fs)
        _("./src/form.ls").nReadFile('utf-8').promise.then( -> done() )

`o.thenFoo`:
: when `o` eventually resolves, this is essentially equivalent to building a *deferred* `foo(...)`.   

        using(console)
        _('Just').log().thenLog("a").thenLog("sequence").thenLog("of").thenLog("strings").

### History


- 11-22-2013: 
    * Added support for node-style invocation of callbacks (using `Q.nfapply`)
    * Added support for plain sequential invocation of functions without passing input values
     
- 11-05-2013
    * Original release


### Tests

23 passing tests, just run them with:

    npm tests

### License

MIT


 
 [^1]: The `using` clause extends the scope within which **Chained** looks for functions to be chained.
 [^2]: Make, SQL, CSS are all famous examples of DSLs widely used by developers. 



 