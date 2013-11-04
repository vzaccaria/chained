


### Chained Browser Demo

This demo shows a **form validation DSL** implemented with **Chained** in Coffeescript: 

    form '#form', ( check ) ->

        field '#fname', (f) -> 
            check(f.value).isNotNull().isLengthAtLeast(of: 2).show(f)

        field '#lname', (f) -> 
            check(f.value).isNotNull().isLengthAtLeast(of: 2).show(f)

        field '#uname', (f) -> check(f.value).isNotNull().userNameShouldNotExist(msg: 'User already exists').show(f)

        field '#password1', (f) ->
            check(f.value).isNotNull().isLengthAtLeast(of: 4).show(f)

        field '#password2', (f) ->
            check(f.value).isNotNull().shouldMatchElement(element: '#password1', msg: "passwords should match").show(f)

* `form` and `field` functions setup `focusout` callbacks with chained, deferred objects. `check` is an alias for `chained._`.

* The method `show` renders popup error messages whenever one of the  promise associated with a predicate-chain fails.

* The method `userNameShouldNotExist` is based on an Ajax `get` and, as such, is promise based. Chained allows to use the result in the next predicate as if it were synchronous. The users file at the moment contains only the user `zack`.
