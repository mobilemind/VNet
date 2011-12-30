#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
projects = $(projname) $(subprojname)
htmlfiles = $(projname).html $(subprojname).html
manifests = $(projname).manifest $(subprojname).manifest
srcfiles = $(htmlfiles) $(manifests)
htmlcompressor = java -jar lib/htmlcompressor-1.5.2.jar
compressoroptions = -t html -c utf-8 --remove-quotes --remove-intertag-spaces  --remove-surrounding-spaces min --compress-js --compress-css
echoe := $(shell [[ 'cygwin' == $$OSTYPE ]] && echo -e 'echo -e' || echo 'echo\c')
growl := $(shell ! hash growlnotify &>/dev/null && $(echoe) 'true\c' || ([[ 'darwin11' == $$OSTYPE ]] && echo "growlnotify -t $(projname) -m\c" || ([[ 'cygwin' == $$OSTYPE ]] && echo -e "growlnotify /t:$(projname)\c" || $(echoe) '\c')) )
version := $(shell head -1 src/VERSION)
builddate := $(shell date)


default: clean build

copy_src:
	@$(growl) "Make started"
	@(echo '   Copying source files…'; \
		[[ -d build ]] || mkdir -m 744 build; \
		cp -Rfp src/img build; \
		$(foreach proj,$(projects), \
			cp -fp src/$(proj).* .;) \
	)

html: copy_src
# build src to root
	@echo '   Setting version and build date…';
	@(perl -p -i -e "s/\@VERSION\@/$(version)/g;" $(srcfiles); \
		perl -p -i -e "s/\@BUILDDATE\@/$(builddate)/g;" $(srcfiles) \
	)

validate: html
# validate in root
	@$(growl) "Validation started"
	@($(echoe) "   Validating HTML…\n"; \
		hash tidy && ($(foreach html,$(htmlfiles), \
			echo "$(html)"; \
			tidy -eq $(html); [[ $$? -lt 2 ]] && echo;)) \
	)
	@($(echoe) "   Validating JavaScript…\n"; \
		hash jsl && ($(foreach html,$(htmlfiles), \
			echo "$(html)"; \
			jsl -process $(html) -nologo -nofilelisting -nosummary && echo ' OK';)) && echo \
	)

minify: validate
# minify to /build/
	@$(growl) "Compression started"
	@(echo '   Compressing HTML files…'; \
		$(htmlcompressor) $(compressoroptions) --mask *.html -o build $(htmlfiles); \
		cd build; \
		gzip -f $(htmlfiles) \
	)

build: minify
	@echo '   Moving built HTML files to build directory…'
	@($(foreach proj,$(projects), \
			mv -f build/$(proj).html.gz build/$(proj);) \
		$(foreach manifest,$(manifests),\
			mv -f $(manifest) build;) \
		chmod -R 744 build; \
		rm -rf $(projname) $(subprojname) $(srcfiles) *.bak; \
		$(echoe) "Build complete. See /build/ directory for files.\n"; \
		$(growl) "Done. See $(projname)/build directory." \
	)

clean:
	@echo '   Cleaning build folder and root…'
	@rm -rf build/* $(projname) $(subprojname) $(srcfiles) *.bak
