#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
projects = $(projname) $(subprojname)
htmlfiles = $(projname).html $(subprojname).html
compressedfiles = $(projname).html.gz $(subprojname).html.gz
manifests = $(projname).manifest $(subprojname).manifest
htmlcompressor := java -jar $$HOME/common/lib/htmlcompressor-1.5.2.jar
compressoroptions := -t html -c utf-8 --remove-quotes --remove-intertag-spaces  --remove-surrounding-spaces min --compress-js --compress-css
growl := $(shell ! hash growlnotify &>/dev/null && echo 'true' || ([[ 'darwin11' == $$OSTYPE ]] && echo "growlnotify -t $(projname) -m" || ([[ 'cygwin' == $$OSTYPE ]] && echo -e "growlnotify /t:$(projname)\c" || echo)) )
builddate := $(shell date)
replacetokens = perl -p -i -e "s/\@VERSION\@/`head -1 src/VERSION.txt`/g;" $@; perl -p -i -e "s/\@BUILDDATE\@/$(builddate)/g;" $@
# VPATH = src:build:web


default: checkbuild
	@(echo "Done. See $(projname)/web directory"; echo; \
		$(growl) "Done. See $(projname)/web directory." )


.PHONY: checkbuild
checkbuild: $(compressedfiles) $(manifests) imgdir
	@echo '   Moving built HTML files to web directory…'
	@[[ -d web ]] || mkdir -m 744 web
	@($(foreach proj,$(projects), mv -f $(proj).html.gz web/$(proj);) \
		$(foreach manifest,$(manifests), mv -f $(manifest) web;) \
		chmod -R 744 web )

.PHONY: clean
clean:
	@echo '   Cleaning build folder and root…'
	-rm -rf build/* web/* img $(projname) $(subprojname) $(htmlfiles) $(manifests) VERSION.txt *.bak *.gz

.PHONY: html
html: $(htmlfiles) $(manifests) imgdir

.PHONY:	imgdir
imgdir:
	@cp -Rfp src/img .

# run through html compressor and into gzip
%.html.gz: %.html
	@echo "Compressing $^…"; $(htmlcompressor) $(compressoroptions) $^ | gzip > $@

# replace tokens in HTML, then check with tidy & jsl (JavaScript Lint)
%.html: VERSION.txt
	@echo $@; cp -fp src/$@ .; $(replacetokens)
	@hash tidy && (tidy -eq $@; [[ $$? -lt 2 ]] && true)
	@hash jsl && jsl -process $@ -nologo -nofilelisting -nosummary

#replace tokens in manifest
%.manifest: VERSION.txt
	@cp -fp src/$@ .; $(replacetokens)

VERSION.txt:
	@cp src/VERSION.txt .
