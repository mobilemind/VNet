#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
htmlfiles = $(projname).html $(subprojname).html
manifest = $(projname).manifest
srcfiles = $(htmlfiles) $(manifest)
imgdir = iphone
htmlcompressor = java -jar lib/htmlcompressor-1.5.2.jar
compressoroptions = -t html -c utf-8 --remove-quotes --remove-intertag-spaces  --remove-surrounding-spaces min --compress-js --compress-css

default: clean build

copy_src:
	@echo '   Copying source files…'
	@[[ -d web ]] || mkdir -m 744 web
	@mkdir web/$(imgdir)
	@cp -R src/img web/$(imgdir)/img
	@cp src/$(projname).* .
	@cp src/$(subprojname).* .

replace_img: copy_src
	@echo '   Replacing image paths…'
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" $(htmlfiles)
	@perl -p -i -e "s/^img\//iphone\/img\//g;" $(manifest)

set_ver: copy_src replace_img
	@echo '   Setting version and build date…'
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" $(srcfiles)
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" $(srcfiles)

compress_html: copy_src set_ver
	@echo '   Compressing HTML files…'
	@$(htmlcompressor) $(compressoroptions) --mask *.html -o web $(htmlfiles)
	@gzip -f web/$(projname).html web/$(subprojname).html

mv2web: copy_src compress_html
	@echo '   Moving built files to web directory…'
	@mv web/$(projname).html.gz web/$(projname)
	@mv web/$(subprojname).html.gz web/$(subprojname)
	@mv -f $(projname).manifest web
	@chmod -R 744 web

build: mv2web
	@echo "   Removing temporary $(projname) $(subprojname) $(srcfiles) and *.bak"
	@rm -rf $(projname) $(subprojname) $(srcfiles) *.bak
	@echo "Build complete. See web/ directory for $(projname), $(subprojname), $(projname).manifest, and $(imgdir)/."

clean:
	@echo '   Cleaning web folder and root…' && rm -rf web/* $(projname) $(subprojname) $(srcfiles) *.bak 
