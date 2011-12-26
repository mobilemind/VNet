#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
htmlfiles = $(projname).html $(subprojname).html
manifest = $(projname).manifest
srcfiles = $(htmlfiles) $(manifest)
htmlcompressor = java -jar lib/htmlcompressor-1.5.2.jar
compressoroptions = -t html -c utf-8 --remove-quotes --remove-intertag-spaces  --remove-surrounding-spaces min --compress-js --compress-css

default: clean build

copy_src:
	@echo '   Copying source files…'
	@[[ -d build ]] || mkdir -m 744 build
	@cp -Rfp src/img build
	@cp src/$(projname).* .
	@cp src/$(subprojname).* .

set_ver: copy_src
	@echo '   Setting version and build date…'
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" $(srcfiles)
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" $(srcfiles)

compress_html: copy_src set_ver
	@echo '   Compressing HTML files…'
	@$(htmlcompressor) $(compressoroptions) --mask *.html -o build $(htmlfiles)
	@gzip -f web/$(projname).html web/$(subprojname).html

mv2build: copy_src compress_html
	@echo '   Moving built files to web directory…'
	@mv build/$(projname).html.gz build/$(projname)
	@mv build/$(subprojname).html.gz build/$(subprojname)
	@mv -f $(projname).manifest build
	@chmod -R 744 build

build: mv2build
	@echo "   Removing temporary $(projname) $(subprojname) $(srcfiles) and *.bak"
	@rm -rf $(projname) $(subprojname) $(srcfiles) *.bak
	@echo "Build complete. See build/ directory for $(projname), $(subprojname), $(projname).manifest, and $(imgdir)/."

clean:
	@echo '   Cleaning build folder and root…' && rm -rf build/* $(projname) $(subprojname) $(srcfiles) *.bak 
