
vals = [
    { name: "isNotNull"          , pred: (it , opts) -> (it? and it.length > 0)              , msg: 'Can\'t be null' }
    { name: "isLengthAtLeast"    , pred: (it , opts) -> (it.length >= opts.of)               , msg: "Should respect minimum length of 4!" }
    { name: "shouldMatchElement" , pred: (it , opts) -> ($(opts.element).get(0).value == it) , msg: 'Should match'}
    ]

filters = 
          userNameShouldNotExist: (it, opts) ->
                            x = it 

                            success-get = -> 
                                it = JSON.parse(it)
                                val = _.find(it, -> it.uname == x )
                                console.log val
                                if val?
                                    console.log "Already exists!!"
                                    throw opts.msg
                                return x 

                            fail-get = -> 
                                throw "Can't check. Connection error" 

                            x = it
                            
                            return Q($.get('users.json')).then success-get, fail-get

          

filters = _.extend(filters, validators(vals))

console.log filters

error-template = (m) -> """
<div class=\"ui red pointing prompt label transition visible\">#{m}</div>
"""

signal-er = (e,m) ->
    clear-er(e)
    $(e).parent().addClass('error')
    $(e).parent().append(error-template(m))

clear-er = (e) ->
    $(e).parent().removeClass('error')
    $(e).siblings('.prompt').remove()


form = generalForm(filters, signal-er, clear-er)

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





