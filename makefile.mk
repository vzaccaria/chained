# Makefile generated automatically on November 4th 2013, 5:27:18 pm
# (c) 2013 - Vittorio Zaccaria, all rights reserved

# Current configuration: 
BUILD_DIR=./build
DEPLOY_DIR=./deploy
LOCAL_SERVER_DIR=server
LOCAL_CLIENT_DIR=static
SERVER_DIR=./deploy/server
CLIENT_DIR=./deploy/static
CLIENT_DIR_IMG=./deploy/static/img
CLIENT_DIR_FONTS=./deploy/static/font

# Deploy all targets
.PHONY: all
all: 
	 make deploy

# 
CLIENT_HTML= \
	$(strip $(patsubst %, ./build/%, $(patsubst %.md, %.html, $(notdir ./Readme.md)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.md, %.html, $(notdir ./Readme-demo.md)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.jade, %.html, $(notdir ./assets/views/demo.jade)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.jade, %.html, $(notdir ./assets/views/index.jade))))

# 
CLIENT_CSS= \
	$(strip $(patsubst %, ./build/%, $(patsubst %.css, %.css, $(notdir ./assets/css/normalize.css)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.less, %.css, $(notdir ./assets/css/main.less)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.css, %.css, $(notdir ./assets/css/prettify.css)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.css, %.css, $(notdir ./assets/css/solarized.css)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.css, %.css, $(notdir ./assets/components/opentip/opentip.css))))

# Merges file list into ./build/client.css
./build/client.css: $(CLIENT_CSS)
	 cat $^ > $@

# 
CLIENT_SOURCES= \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/dsl.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/chain.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/form.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/browser-demo.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/entry-demo.ls))))

# Merges file list into ./build/client.js
./build/client.js: $(CLIENT_SOURCES)
	 cat $^ > $@

# 
SERVER_SOURCES= \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/dsl.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/dsl-test.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/chain.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.coffee, %.js, $(notdir src/demo.coffee)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.ls, %.js, $(notdir src/entry.ls)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.js, %.js, $(notdir ./assets/components/opentip/opentip-jquery.js))))

# 
VENDOR_CLIENT_SOURCES= \
	$(strip $(patsubst %, ./build/%, $(patsubst %.js, %.js, $(notdir ./lib/jquery.js)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.js, %.js, $(notdir ./lib/reflect.js)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.js, %.js, $(notdir ./lib/q.js)))) \
	$(strip $(patsubst %, ./build/%, $(patsubst %.js, %.js, $(notdir ./lib/underscore.js))))

# Merges file list into ./build/vendor.js
./build/vendor.js: $(VENDOR_CLIENT_SOURCES)
	 cat $^ > $@

# Create temporary directories
.PHONY: pre-build
pre-build: 
	 @mkdir -p ./build

# Create deploy directories
.PHONY: pre-deploy
pre-deploy: 
	 @mkdir -p ./deploy
	 @mkdir -p ./deploy/server
	 @mkdir -p ./deploy/static
	 @mkdir -p ./deploy/static/js
	 @mkdir -p ./deploy/static/css
	 @mkdir -p ./deploy/static/img
	 @mkdir -p ./deploy/static/html

# Deploy files
.PHONY: _deploy
_deploy: 
	 @for i in $(SERVER_SOURCES); do \
		 install -m 555 $$i ./deploy/server; \
	 done 
	 @for i in $(CLIENT_HTML); do \
		 install -m 555 $$i ./deploy/static/html; \
	 done 
	 install -m 555 ./build/client.js ./deploy/static/js
	 install -m 555 ./build/client.css ./deploy/static/css
	 install -m 555 ./build/vendor.js ./deploy/static/js
	 @for i in $(shell find ./assets/img -name '*.png'); do \
		 install -m 555 $$i ./deploy/static/img; \
	 done 
	 @for i in $(shell find ./assets/img -name '*.jpg'); do \
		 install -m 555 $$i ./deploy/static/img; \
	 done 
	 install -m 555 $(strip $(patsubst %, ./build/%, $(patsubst %.jade, %.html, $(notdir ./assets/views/demo.jade)))) ./deploy/static
	 install -m 555 $(strip $(patsubst %, ./build/%, $(patsubst %.jade, %.html, $(notdir ./assets/views/index.jade)))) ./deploy/static
	 @echo ' [34m└─(deployed.[0m' 1>&2
	 @echo ' [34m[0m' 1>&2

# Post deploy files
.PHONY: post-deploy
post-deploy: 
	 ./tools/deploy.coffee -s ./deploy/static -c /Users/zaccaria/development/svn/devel/zaccaria/tools/dsl/ls-dsl -w ./chained deploy -v 
	 cp assets/views/users.json ./deploy/static
	 cp build/entry.js ./deploy/static/js/entry.js
	 cp build/opentip-jquery.js ./deploy/static/js/opentip-jquery.js
	 @rm -rf public
	 @mkdir -p public
	 @cp deploy/server/dsl.js      public
	 @cp deploy/server/dsl-test.js public
	 @cp deploy/server/chain.js    public
	 @echo ' [34m└─(post deploy done.[0m' 1>&2
	 @echo ' [34m[0m' 1>&2

# Build completed
.PHONY: _build
_build:  	 $(CLIENT_HTML)  \
 	 ./build/client.css  \
 	 ./build/client.js  \
 	 $(SERVER_SOURCES)  \
 	 ./build/vendor.js  \
 
	 @echo ' [34m└─(build completed.[0m' 1>&2
	 @echo ' [34m[0m' 1>&2

# Runs task deploy
.PHONY: deploy
deploy: 
	 @make pre-deploy
	 @make build
	 @make _deploy
	 @make post-deploy


# Runs task build
.PHONY: build
build: 
	 @make pre-build
	 @make _build


# Vpath definition
VPATH =  \
	 $(dir ./Readme.md)  \
	 $(dir ./Readme-demo.md)  \
	 $(dir ./assets/views/demo.jade)  \
	 $(dir ./assets/views/index.jade)  \
	 $(dir ./assets/css/normalize.css)  \
	 $(dir ./assets/css/main.less)  \
	 $(dir ./assets/css/prettify.css)  \
	 $(dir ./assets/css/solarized.css)  \
	 $(dir ./assets/components/opentip/opentip.css)  \
	 $(dir src/dsl.ls)  \
	 $(dir src/chain.ls)  \
	 $(dir src/form.ls)  \
	 $(dir src/browser-demo.ls)  \
	 $(dir src/entry-demo.ls)  \
	 $(dir src/dsl.ls)  \
	 $(dir src/dsl-test.ls)  \
	 $(dir src/chain.ls)  \
	 $(dir src/demo.coffee)  \
	 $(dir src/entry.ls)  \
	 $(dir ./assets/components/opentip/opentip-jquery.js)  \
	 $(dir ./lib/jquery.js)  \
	 $(dir ./lib/reflect.js)  \
	 $(dir ./lib/q.js)  \
	 $(dir ./lib/underscore.js)  \

# Start continuous build
.PHONY: server
server: 
	 echo '' > ./.watches.pid
	 @watchman -w ./Readme.md 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w ./Readme-demo.md 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w ./assets 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/dsl.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/chain.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/form.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/browser-demo.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/entry-demo.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/dsl-test.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/demo.coffee 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w src/entry.ls 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -w ./lib 'touch ./.source-changed' & echo "$$!" >> "./.watches.pid" 
	 @watchman -r 1s -w ./deploy/server 'touch ./.server-changed' &
	 @watchman -r 1s -w ./deploy/static 'touch ./.client-changed' &
	 @watchman -r 1s -w ./.source-changed 'make deploy' &
	 @watchman -r 1s -w ./.client-changed 'chromereload' &
	 @pushserve -P ./deploy/static & echo "$$!" >> "./.watches.pid"

# Stops the continuous build
.PHONY: reverse
reverse: 
	 cat ./.watches.pid | xargs -n 1 kill -9

# Sets up tests
.PHONY: pre-ci-test
pre-ci-test: 

# One shot e2e tests app
.PHONY: test
test: deploy

# Tests app after build
.PHONY: ci-test
ci-test: 

# Converting from ls to js
./build/%.js: %.ls
	 lsc --output $(BUILD_DIR) -c $<

# Converting from coffee to js
./build/%.js: %.coffee
	 coffee --output $(BUILD_DIR) $<

# Converting from jade to html
./build/%.html: %.jade
	 @jade -P --out $(BUILD_DIR) $<

# Converting from md to html
./build/%.html: %.md
	 @maruku --html-frag $< -o $@

# Converting from styl to css
./build/%.css: %.styl
	 stylus $< -o $(BUILD_DIR)

# Converting from less to css
./build/%.css: %.less
	 lessc --verbose $< > $@

# Converting from sass to css
./build/%.css: %.sass
	 sass $< $@

# Converting from scss to css
./build/%.css: %.scss
	 sass --scss $< $@

# Converting from js to min.js
./build/%.min.js: ./build/%.js
	 uglifyjs  $< > $@

# Converting from css to min.css
./build/%.min.css: ./build/%.css
	 uglifycss $< > $@

# Converting from js to min.js.gz
./build/%.min.js.gz: ./build/%.js
	 uglifyjs  $< | gzip -c > $@

# Converting from css to min.css.gz
./build/%.min.css.gz: ./build/%.css
	 uglifycss $< | gzip -c > $@

# Converting from js to js
./build/%.js: %.js
	 cp $< $@

# Converting from css to css
./build/%.css: %.css
	 cp $< $@

# Converting from html to html
./build/%.html: %.html
	 cp $< $@
help:
	 @echo 'Makefile targets'
	 @echo ''
	 @echo '    [31mCommon[0m:' 
	 @echo '        [1mdeploy         [0m: (default). complete deal, create directories, build and install; eventually install assets.' 
	 @echo '        [1mbuild          [0m: Compile all files into build directory.' 
	 @echo ''
	 @echo '    [31mContinuous build[0m:' 
	 @echo '        [1mserver         [0m: Starts continuous build.' 
	 @echo '        [1mreverse        [0m: Stops continuous build.' 
	 @echo ''
	 @echo '    [31mOther[0m:' 
	 @echo '        [1mtest           [0m: Run mocha tests.' 
	 @echo ''
	 @echo '    [31mRelease management[0m:' 
	 @echo '        [1mgit-{patch, minor, major}[0m: Commits, tags and pushes the current branch.' 
	 @echo '        [1mnpm-{patch, minor, major}[0m: As git *, but it does publish on npm.' 
	 @echo '        [1mnpm-install    [0m: Install a global link to this package, to use it: [4mnpm link pkgname[0m in the target dir.' 
	 @echo '        [1mnpm-prepare-x  [0m: Prepare npm version update and gittag it x={ patch, minor, major }.' 
	 @echo '        [1mnpm-commit     [0m: Commit version change.' 
	 @echo '        [1mnpm-finalize   [0m: Merge development branch into master and publish npm.' 
	 @echo ''


# Installs a link globally on this machine
.PHONY: npm-install
npm-install: 
	 @echo ' [34m└─(remember to do a `npm link pkg name` in the.[0m' 1>&2
	 @echo ' [34m[0m' 1>&2
	 @echo ' [34m└─(directory of the modules that are going to use this..[0m' 1>&2
	 @echo ' [34m[0m' 1>&2
	 npm link .

# Npm patch
npm-prepare-patch:
	 @echo ' [34mWarning this is going to tag the current dev. branch and merge it to master.[0m' 1>&2
	 @echo ' [34mThe tag will be brought to the master branch.[0m' 1>&2
	 @echo ' [34mAfter this action, do `make npm commit` and `make npm finalize` to[0m' 1>&2
	 @echo ' [34mPublish to the npm repository.[0m' 1>&2
	 git checkout development
	 npm version patch 

npm-patch:
	 @echo ' [34mWarning this is going to tag the current dev. branch and merge it to master.[0m' 1>&2
	 @echo ' [34mThe tag will be brought to the master branch and the package will be published on npm.[0m' 1>&2
	 git checkout development
	 npm version patch 
	 make npm-finalize

# Npm minor
npm-prepare-minor:
	 @echo ' [34mWarning this is going to tag the current dev. branch and merge it to master.[0m' 1>&2
	 @echo ' [34mThe tag will be brought to the master branch.[0m' 1>&2
	 @echo ' [34mAfter this action, do `make npm commit` and `make npm finalize` to[0m' 1>&2
	 @echo ' [34mPublish to the npm repository.[0m' 1>&2
	 git checkout development
	 npm version minor 

npm-minor:
	 @echo ' [34mWarning this is going to tag the current dev. branch and merge it to master.[0m' 1>&2
	 @echo ' [34mThe tag will be brought to the master branch and the package will be published on npm.[0m' 1>&2
	 git checkout development
	 npm version minor 
	 make npm-finalize

# Npm major
npm-prepare-major:
	 @echo ' [34mWarning this is going to tag the current dev. branch and merge it to master.[0m' 1>&2
	 @echo ' [34mThe tag will be brought to the master branch.[0m' 1>&2
	 @echo ' [34mAfter this action, do `make npm commit` and `make npm finalize` to[0m' 1>&2
	 @echo ' [34mPublish to the npm repository.[0m' 1>&2
	 git checkout development
	 npm version major 

npm-major:
	 @echo ' [34mWarning this is going to tag the current dev. branch and merge it to master.[0m' 1>&2
	 @echo ' [34mThe tag will be brought to the master branch and the package will be published on npm.[0m' 1>&2
	 git checkout development
	 npm version major 
	 make npm-finalize

# Git patch
git-patch:
	 @echo ' [34mUpdate version, commit and tag the current branch[0m' 1>&2
	 @echo ' [34mDoes not publish to the npm repository.[0m' 1>&2
	 npm version patch 
	 git push

# Git minor
git-minor:
	 @echo ' [34mUpdate version, commit and tag the current branch[0m' 1>&2
	 @echo ' [34mDoes not publish to the npm repository.[0m' 1>&2
	 npm version minor 
	 git push

# Git major
git-major:
	 @echo ' [34mUpdate version, commit and tag the current branch[0m' 1>&2
	 @echo ' [34mDoes not publish to the npm repository.[0m' 1>&2
	 npm version major 
	 git push

# Commits changes to git
.PHONY: npm-commit
npm-commit: 
	 git commit -a

# Merges changes into master and publish
.PHONY: npm-finalize
npm-finalize: 
	 git checkout master
	 git merge development
	 npm publish .
	 git push
	 git push --tags
	 git checkout development

# Cleanup all files in build and deploy
.PHONY: distclean
distclean: 
	 -rm -rf ./build
	 -rm -rf ./deploy
	 -rm -f ./.source-changed
	 -rm -f ./.build-changed
	 -rm -f ./.recompile-all
	 -rm -f ./.watches.pid

# Cleanup
.PHONY: clean
clean: 
	 -rm -rf ./build
	 -rm -rf ./deploy
