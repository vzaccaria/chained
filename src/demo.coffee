jQuery       = require('jQuery')
underscore   = require('underscore')
string 		 = require('underscore.string')
{ using, _ } = require('./chain').chain.init()
$ 		 	 = require('cheerio')

using(jQuery)
using(underscore)
using(string)
using(console)

extractLinks = (s) ->
		x = []
		($.load(s))('a').each ->
			x.push(@attr('href'))
		return x

getUser = (user) ->
	  _("https://npmjs.org/~#{user}")
	  	.get()
	  	._(extractLinks)
	  	.filter( -> /package/.test(arguments[0]) )
	  	.map( -> "https://npmjs.org#{arguments[0]}" )
	  	.log()
	  	

getUser("vzaccaria")