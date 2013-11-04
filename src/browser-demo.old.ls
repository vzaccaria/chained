
console.log "are we here?"

filters = {

    isNotNull: -> 
        console.log it
        if not (it? and it.length > 0) 
            throw 'Error!'
        else 
            return it

    isLengthAtLeast: (x, a) ->
        (x.length >= a) 

    isLengthBetween: (x, a, b) ->
        (x.length >= a) and (x.length <= b)

}

error-template = (m) -> """
<div class=\"ui red pointing prompt label transition visible\">#{m}</div>
"""

sig-er = (e,m) ->
    cle-er(e)
    $(e).parent().addClass('error')
    $(e).parent().append(error-template(m))

cle-er = (e) ->
    $(e).parent().removeClass('error')
    $(e).siblings('.prompt').remove()

{init, _ } = chain

chain.init().bindScope(filters)

logit = -> console.log it

field = (id, cb) ->
    $(id).focusout cb

field '#fname', ->

    let e = this
        se = -> sig-er(e, "what??")
        ce = -> cle-er(e)
        chain._(e.value).isNotNull().then(ce, se)




