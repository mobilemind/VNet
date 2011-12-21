#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
srcfiles = vnet.html vnetp.html vnet.manifest
imgdir = iphone
compressoroptions = --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css

default: clean build

build:
##
	@echo "   Copying source files…"
	@mkdir $(imgdir)
	@cp -R ./src/img $(imgdir)/img
	@cp ./src/vnet.* .
	@cp ./src/vnetp.* .
##
	@echo "   Replacing image paths…"
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" $(srcfiles)
##
	@echo "   Setting version and build date…"
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" $(srcfiles)
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" $(srcfiles)
##
	@echo "   Compressing HTML files…"
	@java -jar lib/htmlcompressor-1.4.jar $(compressoroptions) -o $(projname) ./vnet.html
	@java -jar lib/htmlcompressor-1.4.jar $(compressoroptions) -o $(subprojname) ./vnetp.html
##
	@echo "   Applying gzip…"
	@gzip $(projname)
	@mv -f ./vnet.gz $(projname)
	@gzip $(subprojname)
	@mv -f ./vnetp.gz $(subprojname)
# comment next line to keep uncompressed HTML
	@rm -f ./vnet.html ./vnetp.html
##
	@echo "Build complete. See $(projname), $(subprojname), $(projname).manifest"

clean:	
	@echo "   Removing $(projname) $(subprojname) $(srcfiles) $(projname) *.bak and $(imgdir) directory"
	@rm -rf $(projname) $(subprojname) $(srcfiles) $(projname)*.bak $(imgdir)
