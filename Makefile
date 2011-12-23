#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
htmlfiles = vnet.html vnetp.html
manifest = vnet.manifest
srcfiles = $(htmlfiles) $(manifest)
imgdir = iphone
htmlcompressor = java -jar lib/htmlcompressor-1.4.jar
compressoroptions = --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css

default: clean build

build:
##
	@echo '   Copying source files…'
	@[[ -d web ]] || mkdir -m 744 web
	@mkdir web/$(imgdir)
	@cp -R src/img web/$(imgdir)/img
	@cp src/$(projname).* .
	@cp src/$(subprojname).* .
##
	@echo '   Replacing image paths…'
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" $(htmlfiles)
	@perl -p -i -e "s/^img\//iphone\/img\//g;" $(manifest)
##
	@echo '   Setting version and build date…'
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" $(srcfiles)
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" $(srcfiles)
	@mv -f $(projname).manifest web
##
	@echo '   Compressing HTML files…'
	@$(htmlcompressor) $(compressoroptions) -o $(projname) $(projname).html
	@$(htmlcompressor) $(compressoroptions) -o $(subprojname) $(subprojname).html
##
	@echo '   Applying gzip…'
	@gzip -f $(projname)
	@mv -f $(projname).gz web/$(projname)
	@mv -f $(projname).html web
	@gzip -f $(subprojname)
	@mv -f $(subprojname).gz web/$(subprojname)
	@mv -f $(subprojname).html web
# comment next line to keep uncompressed HTML
	@(cd web; rm -f $(htmlfiles);) 
##
	@echo "   Removing $(projname) $(subprojname) $(srcfiles) and *.bak"
	@rm -rf $(projname) $(subprojname) $(srcfiles) *.bak
	@chmod -R 744 web
##
	@echo "Build complete. See web/ directory for $(projname), $(subprojname), $(projname).manifest, and $(imgdir)/."

clean:
	@echo '   Cleaning web folder and root…' && rm -rf web/* $(projname) $(subprojname) $(srcfiles) *.bak 
