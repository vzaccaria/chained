# The DSL Toolbox

## Object manipulation

Use the following constructs to build a vocabulary in javascript for your DSL.

* Close implicit calls (spaced dots), function composition:
   
        x . y . z       => x(y(z( — )))

        Beware of the inverse order... Probably not what you want

* Nested function calls as pipes:

        x |> y |> z     => z(y(   x  ))

    Here, `x` is interpreted as a literal, not a function.
    With partial application (`_`), you can do something like:

        x |> map _, (* 2)



## Object creation

* Cascading

        x = new something
        ..property = 1 
        ..property = 2

* Missing methods
 
        x = new something
        ..property 1 
        ..property 2

    where properties can be assigned after validation or actions
    triggered by using a programmatic strategy. Or to build fluent interfaces:

* Chaining

            when('user').clicks.on('#id').redirect.to("x y z").done()
            when('user').types.it.into('#input').write.it.to('#output')
            when('user').types('go').into('#input').show('label')

            <- builder ->                                  

## Pseudo operator overloading

Yeah, that's a hack, but I think is very useful:

    0 `shares-of` 'IBM'     => sharesOf(0, 'IBM')


# Patterns

## Construct this 

    new fromClass 
        ..x = 3
        ..y = 4

## Do that with this 

    with-object account, ->
        mailer.send(@email-address)
        


