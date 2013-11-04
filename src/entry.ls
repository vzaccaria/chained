
console.log "Yup! lurking at the console, ah?"


# message-template = (m) -> """
# <div class=\"ui blue pointing left prompt label transition visible\">#{m}</div>
# """


explain = (selector, content, message) ->
    the-selector = "#selector:contains(#content)"
    $(the-selector).css('text-decoration', 'underline')
    $(the-selector).each ->
        let content
            new Opentip($(this), message, { delay: 0.01, style: 'dark' })
    # $(the-selector).mouseenter -> 
    #     $(the-selector).append(message-template(message))
    # $(the-selector).mouseleave ->
    #     $(the-selector).children(".prompt").remove()

    

$(document).ready ->
    $('#main-content').load 'html/Readme.html', ->
        $('pre').add-class('prettyprint')
        $('hr').add-class('ui section divider')
        prettyPrint()
        explain('span.kwd' , 'get'    , 'from jQuery - gets implicitly the address')
        explain('span.pln' , 'filter' , 'from underscore - gets implicitly the data to filter')
        explain('span.pln' , 'log'    , 'from console - prints data out')
        explain('span.kwd' , 'using'  , 'expands the scope of "Chained" to include a library')

