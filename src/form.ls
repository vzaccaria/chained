
window.field = (id, cb) ->
    $(id).focusout -> 
        margs = [this] +++ arguments[0 to ]
        cb.apply(this, margs)

window.generalForm = (filters, signal-error, clean-error, id, code) -->

    c = chain.init()
    c.bindScope(filters)
    c.add-custom-method 'show', (e) ->

            se = -> 
                signal-error(e, it)

            ce = -> 
                clean-error(e)

            return c.create-new-monad(@promise, ce, se)

    code(c._, c.bindScope)
    console.log "Inizialized!"
    return c


window.validators = (l) ->
    filters = {}

    for k in l 
        let name = k.name, pred = k.pred, msg = k.msg
            filters[name] = (it, opts) ->
                    if pred(it, opts) == false
                        if !opts?.msg?
                            throw msg;
                        else 
                            throw opts.msg
                    else 
                        return arguments[0]
    return filters
