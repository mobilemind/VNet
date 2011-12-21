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
	@mkdir $(imgdir)
	@cp -R ./src/img $(imgdir)/img
	@cp ./src/$(projname).* .
	@cp ./src/$(subprojname).* .
##
	@echo '   Replacing image paths…'
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" $(htmlfiles)
	@perl -p -i -e "s/^img\//iphone\/img\//g;" $(manifest)
##
	@echo '   Setting version and build date…'
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" $(srcfiles)
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" $(srcfiles)
##
	@echo '   Compressing HTML files…'
	@$(htmlcompressor) $(compressoroptions) -o $(projname) $(projname).html
	@$(htmlcompressor) $(compressoroptions) -o $(subprojname) $(subprojname).html
##
	@echo '   Applying gzip…'
	@gzip $(projname)
	@mv -f $(projname).gz $(projname)
	@gzip $(subprojname)
	@mv -f $(subprojname).gz $(subprojname)
# comment next line to keep uncompressed HTML
	@rm -f $(htmlfiles)
##
	@echo "Build complete. See $(projname), $(subprojname), $(projname).manifest"

clean:	
	@echo "   Removing $(projname) $(subprojname) $(srcfiles) $(projname) *.bak and $(imgdir) directory"
	@rm -rf $(projname) $(subprojname) $(srcfiles) $(projname)*.bak $(imgdir)
