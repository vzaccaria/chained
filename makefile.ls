#!/usr/bin/env lsc


{ simple-make, all, x, hooks, plugins} = require 'wmake'

my-files = [
    { name: "src/dsl.ls"                                    , type: \ls }
    { name: "src/dsl-test.ls"                               , type: \ls }
    { name: "src/chain.ls"                                  , type: \ls }
    { name: "src/demo.coffee"                               , type: \coffee }
    { name: "src/entry.ls"                                  , type: \ls }
    { name: "./assets/components/opentip/opentip-jquery.js" , type: \js }

]

client-files = [
    { name: "src/dsl.ls"          , type: \ls }
    { name: "src/chain.ls"        , type: \ls }
    { name: "src/form.ls"         , type: \ls }
    { name: "src/browser-demo.ls" , type: \ls }
    { name: "src/entry-demo.ls"   , type: \ls }
]

js = (x) ->
    { name: x, type: \js }

vendor-files = [     
    js "./lib/jquery.js"
    js "./lib/reflect.js"
    js "./lib/q.js"
    js "./lib/underscore.js"
    # { files-of-type: \js, in: "./assets/components/semantic-ui/src/modules/behavior" }
]

# server-files = [   { name: "./src/server_modules/c-compile.ls" , type: \ls }   ]

css-files   = [ { name: "./assets/css/normalize.css", type: \css } 
                { name: "./assets/css/main.less", type: \less } 
                { name: "./assets/css/prettify.css", type: \css }
                { name: "./assets/css/solarized.css", type: \css }
                { name: "./assets/components/opentip/opentip.css", type: \css }

                ]
                    

                   # { 
                   # name: "./html/app/styles/app.less", 
                   # type: \less , deps: all(files-of-type: \less, in: './html/vendor/styles/bootstrap'), include: './html' }
                   
#                  { name: "./html/vendor/styles/codemirror/ambiance.css",   type: \css  }
#                  { name: "./html/vendor/styles/angular-ui.min.css",        type: \css  }
#                  { name: "./html/vendor/styles/bootstrap-select.css",      type: \css  }]

img-files = [   { files-of-type: \png,  in: "./assets/img"} 
                { files-of-type: \jpg,  in: "./assets/img"} ]
                
# font-files = [  { files-of-type: \woff, in: "./assets/less/fonts" } 
#                 { files-of-type: \otf,  in: "./assets/less/fonts" }
#                 { files-of-type: \eot,  in: "./assets/less/fonts" }
#                 { files-of-type: \svg,  in: "./assets/less/fonts" }
#                 { files-of-type: \ttf,  in: "./assets/less/fonts" } ]

project-name      = "chained"
remote-site-path  = "./#project-name"

hooks.add-hook 'post-deploy', null, (path-system) ->
    x "./tools/deploy.coffee -s ./deploy/static -c #{__dirname} -w #{remote-site-path} deploy -v "

hooks.add-hook 'post-deploy', null, (path-system) ->
    x "cp assets/views/users.json ./deploy/static"

hooks.add-hook 'post-deploy', null, (path-system) ->
    x "cp build/entry.js ./deploy/static/js/entry.js"

hooks.add-hook 'post-deploy', null, (path-system) ->
    x "cp build/opentip-jquery.js ./deploy/static/js/opentip-jquery.js"

hooks.add-hook 'post-deploy', null, (path-system) ->
    x "@rm -rf public"
    x "@mkdir -p public"
    x "@cp deploy/server/dsl.js      public"
    x "@cp deploy/server/dsl-test.js public"
    x "@cp deploy/server/chain.js    public"
    
files = 
        client-js: client-files, 
        server-js: my-files, 
        vendor-js: vendor-files, 
        client-css: css-files, 
        client-img: img-files,
        # client-fonts: font-files
        client-html: [  { name: "./Readme.md", type: \md }
                        { name: "./Readme-demo.md", type: \md }
                        { name: "./assets/views/demo.jade" , type: \jade, +root }
                        { name: "./assets/views/index.jade", type: \jade, +root, +serve } ]
        options: {  }
                     
simple-make ( files )





